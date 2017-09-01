namespace :league_rankings do
  task create_missing_rounds: :environment do
    current_league = League.playing.order(starts_at: :asc).first
    current_league = League.opened.order(starts_at: :asc).first unless current_league
    return unless current_league
    current_round = current_league.last_round
    return unless current_round > 1

    puts 'Preparing missing league rankings to import'
    rankings  = []
    current_round_rankings = current_league.league_rankings.where(round: current_round).order(total_points: :desc)
    last_position = current_round_rankings.last.position + 1
    previous_round_rankings = current_league.league_rankings.where(round: current_round - 1)
    not_playing_user_ids = previous_round_rankings.pluck(:user_id) - current_round_rankings.pluck(:user_id)
    puts "Detected #{not_playing_user_ids.count} missing rankings"

    previous_round_rankings.where(user_id: not_playing_user_ids).all.each do |ranking|
      movement = last_position - ranking.position
      rankings << LeagueRanking.new(user_id: ranking.user_id, round: current_round, league: current_league, position: last_position, status: :playing, total_points: ranking.total_points, round_points: 0, movement: movement)
      puts "New league rankings for user #{ranking.user_id} for round #{current_round}"
    end
    puts "Importing #{rankings.count} new rankings"
    LeagueRanking.import(rankings)
    puts 'Finished rankings import'
  end

  task recalculate_total_points: :environment do
    current_league = League.playing.order(starts_at: :asc).first
    current_league = League.opened.order(starts_at: :asc).first unless current_league
    return unless current_league

    puts 'Preparing league rankings to recalculate total points'
    ranking_ids, rankings_data = [], []
    User.find_each do |user|
      rankings = user.league_rankings.where(league: current_league).order(round: :asc)
      if rankings.exists?
        puts "Recalculating total points for user #{user.id}"
        total_points = 0
        rankings.each do |ranking|
          total_points += ranking.round_points
          ranking_ids << ranking.id
          rankings_data << { total_points: total_points }
          puts "Total points #{total_points} in round #{ranking.round}"
        end
      end
    end
    puts 'Updating all rankings'
    LeagueRanking.update(ranking_ids, rankings_data)
    puts 'Finished rankings update'
  end

  task sort_league_rankings: :environment do
    current_league = League.playing.order(starts_at: :asc).first
    current_league = League.opened.order(starts_at: :asc).first unless current_league
    return unless current_league
    current_round = current_league.last_round

    puts 'Preparing league rankings for order'
    next_position = 1
    ranking_ids, rankings_data = [], []
    current_round_rankings = current_league.league_rankings.where(round: current_round).order(total_points: :desc)
    current_round_rankings.group_by(&:total_points).each do |(points, rankings)|
      puts "Preparing #{rankings.count} rankings with #{points} points at #{next_position} position"
      position = next_position
      rankings.each do |ranking|
        ranking_ids << ranking.id
        rankings_data << { position: position }
      end
      next_position += rankings.count
    end
    puts 'Updating all rankings'
    LeagueRanking.update(ranking_ids, rankings_data)
    puts 'Finished rankings update'
  end

  task recalculate_movement: :environment do
    current_league = League.playing.order(starts_at: :asc).first
    current_league = League.opened.order(starts_at: :asc).first unless current_league
    return unless current_league

    puts 'Preparing league rankings to recalculate movement'
    ranking_ids, rankings_data = [], []
    User.find_each do |user|
      rankings = user.league_rankings.where(league: current_league).order(round: :asc)
      if rankings.exists?
        puts "Recalculating movement for user #{user.id}"
        prev_position = nil
        rankings.each do |ranking|
          movement = prev_position ? (ranking.position - prev_position) : 0
          prev_position = ranking.position
          ranking_ids << ranking.id
          rankings_data << { movement: movement }
          puts "Movement #{movement} in round #{ranking.round}"
        end
      end
    end
    puts 'Updating all rankings'
    LeagueRanking.update(ranking_ids, rankings_data)
    puts 'Finished rankings update'
  end
end
