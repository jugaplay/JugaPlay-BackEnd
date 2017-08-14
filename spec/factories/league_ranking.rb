FactoryGirl.define do
  factory :league_ranking do
    user
    league
    round { 1 }
    status { :opened }
    round_points { 0 }
    total_points { 0 }
    position { LeagueRanking.last.nil? ? 1 : (LeagueRanking.last.position + 1) }
  end
end
