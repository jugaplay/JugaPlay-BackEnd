class TableDoesNotHaveAMultiplierChipsCostDefined < StandardError
  def initialize
    super 'Given table does not have a multiplier chips cost defined'
  end
end
