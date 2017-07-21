class Numeric
  def coins
    Money.coins(self)
  end
  alias :coin :coins

  def chips
    Money.chips(self)
  end
  alias :chip :chips
end
