class PointsForWinners
  def self.default
    [1000, 700, 600, 500, 475, 475, 450, 450, 450, 450] +
    10.times.map { 425 } +
    11.times.map { 400 } +
    15.times.map { 375 } +
    14.times.map { 350 } +
    15.times.map { 325 } +
    12.times.map { 300 } +
    13.times.map { 275 } +
    20.times.map { 250 } +
    30.times.map { 225 } +
    25.times.map { 200 } +
    25.times.map { 175 }
  end
end