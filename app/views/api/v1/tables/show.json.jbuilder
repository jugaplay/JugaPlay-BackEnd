json.id @table.id
json.title @table.title
json.number_of_players @table.number_of_players
json.entry_coins_cost @table.entry_coins_cost
json.start_time @table.start_time.strftime('%d/%m/%Y - %H:%M')
json.end_time @table.end_time.strftime('%d/%m/%Y - %H:%M')
json.description @table.description

json.points_for_winners(@table.points_for_winners) do |points|
  json.points points
end

json.winners(@table.winners) do |winner|
  json.user_id winner.user_id
  json.user_email winner.user.email
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
