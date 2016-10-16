json.id @table.id
json.title @table.title
json.has_password false # TODO: sacar esto
json.number_of_players @table.number_of_players
json.entry_coins_cost @table.entry_coins_cost
json.tournament_id  @table.tournament_id
json.start_time @table.start_time.strftime('%d/%m/%Y - %H:%M')
json.end_time @table.end_time.strftime('%d/%m/%Y - %H:%M')
json.description @table.description

json.prizes! @table.coins_for_winners.each_with_index.to_a do |(coins, index)|
  json.position index
  json.coins coins
end

unless @table.closed?
  json.playing(@table.plays) do |play|
    json.user_id play.user.id
    json.user_mail play.user.email
    json.nickname play.user.nickname
    if play.user.rankings.first.present?
      json.ranking_tournament_points play.user.rankings.first.points
      json.ranking_tournament_position play.user.rankings.first.position
    end
    json.players(play.players) do |player|
      json.player_id player.id
    end
  end
end

json.winners(@table.winners) do |winner|
  json.user_id winner.user_id
  json.user_email winner.user.email
  json.nickname winner.user.nickname
  json.bet_coins winner.user.play_of_table(@table).bet_coins
  json.position winner.position
  json.points @table.points_for_winners[winner.position - 1]
end

json.matches do
  json.partial! partial: 'api/v1/matches/match', collection: @table.matches, as: :match
end

json.table_rules do
  json.partial! partial: 'api/v1/tables_rules/table_rules', locals: { table_rules: @table.table_rules }
end
