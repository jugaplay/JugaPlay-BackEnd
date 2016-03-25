class PlaysHistory
  def initialize(scope = Play)
    @scope = scope
  end

  def of_table(table)
    @scope = scope.where(table: table) if table.present?
    self
  end

  def made_by(user)
    @scope = scope.where(user: user) if user.present?
    self
  end

  def highest_scores
    @scope = scope.where(points: scope.maximum(:points))
    self
  end

  private
  attr_reader :scope

  def method_missing(method, *args, &block)
    scope.send(method, *args, &block)
  end
end
