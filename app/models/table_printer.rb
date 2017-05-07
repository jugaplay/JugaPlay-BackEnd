class TablePrinter
  def initialize(keys, values)
    @keys = keys
    @values = values
    @max_length = {}
    keys.each do |key|
      @max_length[key] = key.to_s.length
      values.each do |value|
        value_length = value[key].to_s.length
        @max_length[key] = value_length if value_length > @max_length[key]
      end
    end
  end

  def call
    format = '| ' + keys.map { |key| "%#{max_length[key]}s" }.join(' | ') + " |\n"
    max_line_length = max_length.values.sum + (keys.size * 3) + 1

    printf("%s\n", '-' * max_line_length)
    printf(format, *(keys.map(&:to_s).map(&:upcase)))
    printf("%s\n", '-' * max_line_length)
    values.each do |value|
      printf(format, *(value.values.map(&:to_s)))
    end
    printf("%s\n", '-' * max_line_length)
    nil
  end

  private
  attr_reader :keys, :values, :max_length
end
