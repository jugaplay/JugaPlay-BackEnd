
json.withdraws(@transactions) do |transaction|
	
	json.user_id transaction.user_id
	json.user_email transaction.user.email
	json.coins transaction.coins
	json.detail transaction.detail
	json.date transaction.created_at
	
end


json.entry_fees(@t_entry_fees) do |t_entry_fee|
	
	json.user_id t_entry_fee.user_id
	json.user_email t_entry_fee.user.email
	json.coins t_entry_fee.coins
	json.detail t_entry_fee.detail
	json.date t_entry_fee.created_at
	
end

json.deposits(@t_deposits) do |t_deposit|
	
	json.user_id t_deposit.user_id
	json.user_email t_deposit.user.email
	json.coins t_deposit.coins
	json.detail t_deposit.detail
	json.date t_deposit.created_at
	
end

json.prizes(@t_prizes) do |t_prize|
	
	json.user_id t_prize.user_id
	json.user_email t_prize.user.email
	json.coins t_prize.coins
	json.detail t_prize.detail
	json.date t_prize.created_at
	
end