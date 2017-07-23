json.total_withdraws @total_of_transactions
json.last_month_withdraws @last_month_transactions

json.detail_withdraws(@transactions) do |transaction|
	json.coins transaction.coins
	json.detail transaction.detail
	json.date transaction.created_at
end

json.total_entry_fees @total_of_t_entry_fees
json.last_month_entry_fees @last_month_t_entry_fees

json.detail_entry_fees(@t_entry_fees) do |t_entry_fee|
	json.id t_entry_fee.id
	json.coins t_entry_fee.coins
	json.detail t_entry_fee.detail
	json.table_id t_entry_fee.table_id
	json.tournament_id t_entry_fee.tournament_id	
	json.date t_entry_fee.created_at
end

json.total_deposits @total_of_t_deposits
json.last_month_deposits @last_month_t_deposits

json.detail_deposits(@t_deposits) do |t_deposit|
	json.coins t_deposit.coins
	json.detail t_deposit.detail
	json.price t_deposit.price
	json.date t_deposit.created_at
end

json.total_prizes @total_earned_coins
json.last_month_prizes @last_month_earned_coins

json.detail_prizes(@table_rankings) do |table_ranking|
	json.coins table_ranking.prize.value
	json.detail table_ranking.detail
	json.date table_ranking.created_at
end

json.total_promotions @total_of_t_promotions
json.last_month_promotions @last_month_t_promotions

json.detail_promotions(@t_promotions) do |t_promotion|
	json.coins t_promotion.coins
	json.detail t_promotion.detail
	json.promotion_type t_promotion.promotion_type
	json.date t_promotion.created_at
end
