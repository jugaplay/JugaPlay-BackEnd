class LeagueRankingCalculator

  def initialize(evaluation_time, table)
    @plays = table.league_plays
    @evaluation_time = evaluation_time
  end

  def call
     close_current_league_and_pick_next_league if should_be_closed
    if current_league
      mark_league_as_playing_if_necessary
      end_old_league_rankings
      prepare_league_rankings
      update_plays_and_points
      update_total_points
      sort_rankings
      update_movement
      create_rankings_for_non_playing_users
    end
  end

  private
  attr_reader :plays, :evaluation_time

  def mark_league_as_playing_if_necessary
    current_league.update_attributes!(status: :playing) if current_league.opened?
  end

  def end_old_league_rankings
    if current_round > 1
      old_rankings = LeagueRanking.playing.where(league: current_league, round: current_round - 1).order(id: :asc)
      old_rankings.update_all(status_cd: LeagueRanking.statuses[:ended])
      notifications = old_rankings.map { |ranking| build_notification ranking }
      Notification.import(notifications)
    end
  end

  def prepare_league_rankings
    new_rankings = []
    plays.each do |play|
      user = play.user
      ranking = LeagueRanking.playing.find_by(league: current_league, user: user, round: current_round)
      new_rankings << build_league_ranking_for(user) unless ranking
    end
    LeagueRanking.import(new_rankings)
  end

  def update_plays_and_points
    plays.each do |play|
      user = play.user
      ranking = LeagueRanking.playing.find_by(league: current_league, user: user, round: current_round)
      ranking = build_league_ranking_for(user) unless ranking
      ranking.plays << play
      ranking.round_points = ranking.best_plays.pluck(:points).sum
      ranking.save!
    end
  end

  def sort_rankings
    next_position = 1
    ranking_ids, rankings_data = [], []
    current_round_rankings.group_by(&:total_points).each do |(points, rankings)|
      position = next_position
      rankings.each do |ranking|
        ranking_ids << ranking.id
        rankings_data << { position: position }
      end
      next_position += rankings.count
    end
    LeagueRanking.update(ranking_ids, rankings_data)
  end

  def update_total_points
    ranking_ids, rankings_data = [], []
    plays.each do |play|
      user = play.user
      prev_total_points = 0
      LeagueRanking.where(league: current_league, user: user).order(round: :asc).all.each do |ranking|
        total_points = prev_total_points + ranking.round_points
        prev_total_points = total_points
        ranking_ids << ranking.id
        rankings_data << { total_points: total_points }
      end
    end
    LeagueRanking.update(ranking_ids, rankings_data)
  end

  def update_movement
    ranking_ids, rankings_data = [], []
    plays.each do |play|
      user = play.user
      prev_position = nil
      LeagueRanking.where(league: current_league, user: user).order(round: :asc).all.each do |ranking|
        movement = prev_position ? (ranking.position - prev_position) : 0
        prev_position = ranking.position
        ranking_ids << ranking.id
        rankings_data << { movement: movement }
      end
    end
    LeagueRanking.update(ranking_ids, rankings_data)
  end

  def create_rankings_for_non_playing_users
    return unless current_round > 1
    rankings  = []
    last_position = current_round_rankings.last.position + 1
    previous_round_rankings = current_league.league_rankings.where(round: current_round - 1)
    not_playing_user_ids = previous_round_rankings.pluck(:user_id) - current_round_rankings.pluck(:user_id)
    previous_round_rankings.where(user_id: not_playing_user_ids).all.each do |ranking|
      movement = last_position - ranking.position
      rankings << LeagueRanking.new(user_id: ranking.user_id, round: current_round, league: current_league, position: last_position, status: :playing, total_points: ranking.total_points, round_points: 0, movement: movement)
    end
    LeagueRanking.import(rankings)
  end

  def close_current_league_and_pick_next_league
    notifications = []
    current_league.update_attributes!(status: :closed)
    last_round_rankings = current_league.last_round_rankings.order(total_points: :desc)
    last_round_rankings.update_all(status_cd: LeagueRanking.statuses[:ended])
    last_round_rankings.group_by(&:total_points).each_with_index do |(points, rankings), index|
      position = index + 1
      prize = current_league.prize_for_position(position)
      rankings.each do |ranking|
        ranking.user.win_money! prize
        notifications << build_notification(ranking)
      end
    end
    Notification.import(notifications)
    @current_league = League.where('starts_at <= ?', evaluation_time).opened.order(starts_at: :asc).first
    @current_round = ((evaluation_time - current_league.starts_at) / current_league.frequency).to_i + 1
  end

  def current_league
    @current_league ||= begin
      league = League.playing.order(starts_at: :asc).first
      league = League.opened.order(starts_at: :asc).first unless league
      league
    end
  end

  def current_round
    @current_round ||= ((evaluation_time - current_league.starts_at) / current_league.frequency).to_i + 1
  end

  def current_round_rankings
    current_league.league_rankings.where(round: current_round).order(total_points: :desc)
  end

  def build_league_ranking_for(user)
    LeagueRanking.new(user: user, round: current_round, league: current_league, position: 1, status: :playing, total_points: 0, round_points: 0, movement: 0)
  end

  def should_open_new_ranking?(ranking)
    ranking.round < current_round
  end

  def should_be_closed
    return false unless current_league
    league_days = current_league.frequency * current_league.periods
    end_at = current_league.starts_at + league_days
    evaluation_time > end_at
  end

  def build_notification(ranking)
    title = "{\"round\": #{ranking.round}, \"status\": #{ranking.status_cd} }"
    text = "{\"position\": #{ranking.position}, \"points_acumulative\": #{ranking.total_points}, \"movement\": #{ranking.movement}}"
    action = "{\"league_id\": #{ranking.league_id}}"
    Notification.league(user: ranking.user, title: title, text: text, action: action)
  end
end
