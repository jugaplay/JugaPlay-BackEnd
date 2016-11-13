class UsersSearchEngine
  def initialize(scope = User)
    @scope = scope
  end

  def with_name_nickname_or_email_including(some_string)
    where_clause = 'LOWER(first_name) like :some_string OR '
    where_clause += 'LOWER(last_name) like :some_string OR '
    where_clause += 'LOWER(email) like :some_string OR '
    where_clause += 'LOWER(nickname) like :some_string'
    @scope = scope.where(where_clause, { some_string: "%#{some_string.downcase}%" })
    self
  end

  def playing_tournament(tournament_id)
    @scope = scope.joins(:rankings).where(rankings: { tournament_id: tournament_id })
    self
  end

  def sorted_by_ranking
    @scope = scope.select('users.*, rankings.points').joins(:rankings).order('rankings.points DESC').distinct
    self
  end

  def sorted_by_name
    @scope = scope.order(:first_name, last_name: :asc)
    self
  end

  private
  attr_reader :scope

  def method_missing(method, *args, &block)
    scope.send(method, *args, &block)
  end
end
