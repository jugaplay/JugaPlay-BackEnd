json.id table_ranking.id
json.prize_type table_ranking.prize.currency
json.prize_value table_ranking.prize.value
json.table_id table_ranking.table.id
json.detail table_ranking.detail
json.date table_ranking.created_at.iso8601

# POR RETROCOMPATIBILIDAD #
json.coins (table_ranking.prize.coins? ? table_ranking.prize.value : 0)
###########################
