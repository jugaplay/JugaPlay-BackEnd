

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
	json.date t_deposit.created_at
	
end

json.total_prizes @total_of_t_prizes
json.last_month_prizes @last_month_t_prizes

json.detail_prizes(@t_prizes) do |t_prize|

	json.coins t_prize.coins
	json.detail t_prize.detail
	json.prize_id t_prize.prize_id
	json.date t_prize.created_at
	
end