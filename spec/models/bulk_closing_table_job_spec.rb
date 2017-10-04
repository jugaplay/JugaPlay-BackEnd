require 'spec_helper'

describe BulkClosingTableJob do
  let(:job) { BulkClosingTableJob.new }
  let(:yesterday) { Time.now - 1.day }

  context 'given multiple closing table jobs' do
    let!(:pending_job) { FactoryGirl.create(:closing_table_job, status: :pending) }
    let!(:another_pending_job) { FactoryGirl.create(:closing_table_job, status: :pending) }
    let!(:finished_successfully_job) { FactoryGirl.create(:closing_table_job, status: :finished_successfully, stopped_at: yesterday) }
    let!(:failed_job) { FactoryGirl.create(:closing_table_job, status: :failed, failures: 3, stopped_at: yesterday, error_message: 'failed') }

    before do
      create_empty_stats_for_all pending_job.table.matches
      create_empty_stats_for_all another_pending_job.table.matches
      create_empty_stats_for_all finished_successfully_job.table.matches
      create_empty_stats_for_all failed_job.table.matches
    end

    context 'when all the tables are being closed' do
      before do
        pending_job.table.start_closing!
        another_pending_job.table.start_closing!
      end

      it 'closes the tables that belong to a pending jobs' do
        job.call

        pending_job.reload
        another_pending_job.reload
        finished_successfully_job.reload
        failed_job.reload

        expect(pending_job.table).to be_closed
        expect(pending_job.status).to eq :finished_successfully
        expect(pending_job.stopped_at).not_to be_nil
        expect(pending_job.error_message).to be_nil

        expect(another_pending_job.table).to be_closed
        expect(another_pending_job.status).to eq :finished_successfully
        expect(another_pending_job.stopped_at).not_to be_nil
        expect(another_pending_job.error_message).to be_nil

        expect(finished_successfully_job.table).not_to be_closed
        expect(finished_successfully_job.status).to eq :finished_successfully
        expect(finished_successfully_job.stopped_at).to eq yesterday
        expect(finished_successfully_job.error_message).to be_nil

        expect(failed_job.table).not_to be_closed
        expect(failed_job.status).to eq :failed
        expect(failed_job.stopped_at).to eq yesterday
        expect(failed_job.error_message).to eq 'failed'
      end
    end

    context 'when some tables are already closed' do
      before do
        pending_job.table.start_closing!
        another_pending_job.table.close!
      end

      it 'closes the opened tables that belong to a pending job and ignores the closed ones' do
        job.call

        pending_job.reload
        another_pending_job.reload
        finished_successfully_job.reload
        failed_job.reload

        expect(pending_job.table).to be_closed
        expect(pending_job.status).to eq :finished_successfully
        expect(pending_job.stopped_at).not_to be_nil
        expect(pending_job.error_message).to be_nil

        expect(another_pending_job.table).to be_closed
        expect(another_pending_job.status).to eq :finished_successfully
        expect(another_pending_job.stopped_at).not_to be_nil
        expect(another_pending_job.error_message).to be_nil

        expect(finished_successfully_job.table).not_to be_closed
        expect(finished_successfully_job.status).to eq :finished_successfully
        expect(finished_successfully_job.stopped_at).to eq yesterday
        expect(finished_successfully_job.error_message).to be_nil

        expect(failed_job.table).not_to be_closed
        expect(failed_job.status).to eq :failed
        expect(failed_job.stopped_at).to eq yesterday
        expect(failed_job.error_message).to eq 'failed'
      end
    end
  end

  context 'given one closing table job pending' do
    let!(:pending_job) { FactoryGirl.create(:closing_table_job, table: table, status: :pending) }
    let(:tournament) { table.tournament }
    let(:plays_creator) { PlaysCreator.for(table) }
    let(:players_stats) { PlayerStats.for_table table }
    let(:table_rules) { FactoryGirl.create(:table_rules, scored_goals: 1) }

    describe 'for public tables' do
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, points_for_winners: [], prizes: [50.coins, 20.coins]) }

      context 'when one user plays for a player that scores 2 goals and other user plays for a player that scores 5' do
        let(:first_user) { FactoryGirl.create(:user, :without_coins) }
        let(:first_match) { table.matches.first }
        let(:player_of_the_first_user) { first_match.local_team.players.last }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: first_match, scored_goals: 2) }
        let(:first_user_play) { PlaysHistory.new.made_by(first_user).in_table(table).last }

        let(:second_user) { FactoryGirl.create(:user, :without_coins) }
        let(:last_match) { table.matches.last }
        let(:player_of_the_second_user) { last_match.visitor_team.players.first }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: last_match, scored_goals: 5) }
        let(:second_user_play) { PlaysHistory.new.made_by(second_user).in_table(table).last }

        before do
          plays_creator.create_play(user: first_user, players: [player_of_the_first_user], bet: true)
          plays_creator.create_play(user: second_user, players: [player_of_the_second_user], bet: true)
          create_empty_stats_for_all table.matches
          table.start_closing!
        end

        it 'finishes the job successfully' do
          job.call
          pending_job.reload

          expect(pending_job.status).to eq :finished_successfully
          expect(pending_job.stopped_at).not_to be_nil
          expect(pending_job.error_message).to be_nil
        end

        it 'closes the table and updates the total points for each user' do
          job.call
          table.reload

          expect(table).to be_closed
          expect(table.table_rankings).to have(2).item
          expect(table.table_rankings.first.user).to eq second_user
          expect(table.table_rankings.first.position).to eq 1
          expect(table.table_rankings.second.user).to eq first_user
          expect(table.table_rankings.second.position).to eq 2

          expect(first_user_play.points).to eq 2
          expect(first_user.reload.coins).to eq 20.coins
          expect(first_user.ranking_on_tournament(tournament).points).to eq 2.0
          expect(first_user.ranking_on_tournament(tournament).position).to eq 2

          expect(second_user_play.points).to eq 5
          expect(second_user.reload.coins).to eq 50.coins
          expect(second_user.ranking_on_tournament(tournament).points).to eq 5.0
          expect(second_user.ranking_on_tournament(tournament).position).to eq 1
        end

        it 'sends one email to each user with the results of their plays' do
          job.call

          results_emails = ResultsMailer.deliveries
          expect(results_emails).to have(2).items

          expect(results_emails.first.to).to include first_user.email
          expect(results_emails.first.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.first.body).to include "Los Resultados de #{table.title}"

          expect(results_emails.second.to).to include second_user.email
          expect(results_emails.second.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.second.body).to include "Los Resultados de #{table.title}"
        end
      end
    end

    describe 'for private tables' do
      let(:group) { FactoryGirl.create(:group) }
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, group: group, entry_cost: 99.coins, points_for_winners: []) }

      context 'when one user plays for a player that scores 2 goals and other user plays for a player that scores 5' do
        let(:first_user) { FactoryGirl.create(:user, :with_coins, coins: 99.coins) }
        let(:first_match) { table.matches.first }
        let(:player_of_the_first_user) { first_match.local_team.players.last }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: first_match, scored_goals: 2) }
        let(:first_user_play) { PlaysHistory.new.made_by(first_user).in_table(table).last }

        let(:second_user) { FactoryGirl.create(:user, :with_coins, coins: 99.coins) }
        let(:last_match) { table.matches.last }
        let(:player_of_the_second_user) { last_match.visitor_team.players.first }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: last_match, scored_goals: 5) }
        let(:second_user_play) { PlaysHistory.new.made_by(second_user).in_table(table).last }

        before do
          group.update_attributes!(users: [first_user, second_user])
          plays_creator.create_play(user: first_user, players: [player_of_the_first_user], bet: true)
          plays_creator.create_play(user: second_user, players: [player_of_the_second_user], bet: true)
          create_empty_stats_for_all table.matches
          table.start_closing!
        end

        it 'finishes the job successfully' do
          job.call
          pending_job.reload

          expect(pending_job.status).to eq :finished_successfully
          expect(pending_job.stopped_at).not_to be_nil
          expect(pending_job.error_message).to be_nil
        end

        it 'closes the table and updates the total points for each user' do
          pot_prize = table.entry_cost * 2

          job.call
          table.reload

          expect(table).to be_closed
          expect(table.points_for_winners).to be_empty
          expect(table.prizes).to eq [pot_prize]
          expect(table.prizes_type).to eq table.entry_cost.currency
          expect(table.table_rankings).to have(2).item
          expect(table.table_rankings.first.user).to eq second_user
          expect(table.table_rankings.first.position).to eq 1
          expect(table.table_rankings.second.user).to eq first_user
          expect(table.table_rankings.second.position).to eq 2

          expect(first_user_play.points).to eq 2
          expect(first_user.reload.coins).to eq 0.coins
          expect(first_user.ranking_on_tournament(tournament)).to be_nil

          expect(second_user_play.points).to eq 5
          expect(second_user.reload.coins).to eq pot_prize
          expect(second_user.ranking_on_tournament(tournament)).to be_nil
        end

        it 'sends one email to each user with the results of their plays' do
          job.call

          results_emails = ResultsMailer.deliveries
          expect(results_emails).to have(2).items

          expect(results_emails.first.to).to include first_user.email
          expect(results_emails.first.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.first.body).to include "Los Resultados de #{table.title}"

          expect(results_emails.second.to).to include second_user.email
          expect(results_emails.second.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.second.body).to include "Los Resultados de #{table.title}"
        end
      end
    end
  end
end
