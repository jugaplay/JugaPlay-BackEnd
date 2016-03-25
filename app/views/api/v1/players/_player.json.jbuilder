json.id player.id
json.first_name player.first_name
json.last_name player.last_name
json.position player.position
json.description player.description
json.birthday player.birthday.strftime('%d/%m/%Y')
json.nationality player.nationality
json.weight player.weight
json.height player.height
json.data_factory_id player.data_factory_id_if_none { 'N/A' }
