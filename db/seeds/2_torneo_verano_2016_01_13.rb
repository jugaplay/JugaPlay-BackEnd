boca = Team.find_by(name: 'Boca Juniors')
san_lorenzo = Team.find_by(name: 'San Lorenzo')
independiente = Team.find_by(name: 'Independiente')
racing = Team.find_by(name: 'Racing')

## ALTAS
Player.create!(first_name: 'Roger', last_name: 'Martinez', position: 'forward', description: '-', birthday: DateTime.strptime('23/6/94', '%d/%m/%y'), nationality: 'Colombia', weight: 76, height: 1.80, team: racing)
Player.create!(first_name: 'Federico', last_name: 'Carrizo', position: 'forward', description: '-', birthday: DateTime.strptime('17/5/91', '%d/%m/%y'), nationality: 'Argentina', weight: 68, height: 1.70, team: boca)
Player.create!(first_name: 'Luciano', last_name: 'Acosta', position: 'forward', description: '-', birthday: DateTime.strptime('31/5/94', '%d/%m/%y'), nationality: 'Argentina', weight: 59, height: 1.60, team: boca)
Player.create!(first_name: 'Julian', last_name: 'Albertengo', position: 'forward', description: '-', birthday: DateTime.strptime('30/1/91', '%d/%m/%y'), nationality: 'Argentina', weight: 73, height: 1.78, team: independiente)
Player.create!(first_name: 'Gabriel', last_name: 'Valles', position: 'defender', description: '-', birthday: DateTime.strptime('31/5/86', '%d/%m/%y'), nationality: 'Argentina', weight: 65, height: 1.69, team: independiente)
Player.create!(first_name: 'Cristian', last_name: 'Tula', position: 'defender', description: '-', birthday: DateTime.strptime('28/1/78', '%d/%m/%y'), nationality: 'Argentina', weight: 71, height: 1.76, team: independiente)
Player.create!(first_name: 'Mauricio', last_name: 'Victorino', position: 'defender', description: '-', birthday: DateTime.strptime('31/5/86', '%d/%m/%y'), nationality: 'Uruguay', weight: 78, height: 1.82, team: independiente)
Player.create!(first_name: 'Juan Martin', last_name: 'Lucero', position: 'forward', description: '-', birthday: DateTime.strptime('30/11/91', '%d/%m/%y'), nationality: 'Argentina', weight: 72, height: 1.79, team: independiente)
Player.create!(first_name: 'Martin', last_name: 'Campaña ', position: 'goalkeeper', description: '-', birthday: DateTime.strptime('29/5/89', '%d/%m/%y'), nationality: 'Argentina', weight: 85, height: 1.85, team: independiente)
Player.create!(first_name: 'Fabian', last_name: 'Montserrat', position: 'midfielder', description: '-', birthday: DateTime.strptime('25/9/92', '%d/%m/%y'), nationality: 'Argentina', weight: 63, height: 1.65, team: independiente)
Player.create!(first_name: 'Facundo', last_name: 'Quignon', position: 'midfielder', description: '-', birthday: DateTime.strptime('2/5/93', '%d/%m/%y'), nationality: 'Argentina', weight: 73, height: 1.78, team: san_lorenzo)
Player.create!(first_name: 'Alejandro', last_name: 'Barbaro', position: 'midfielder', description: '-', birthday: DateTime.strptime('20/1/92', '%d/%m/%y'), nationality: 'Argentina', weight: 75, height: 1.77, team: san_lorenzo)
Player.create!(first_name: 'Alan', last_name: 'Ruiz', position: 'midfielder', description: '-', birthday: DateTime.strptime('19/8/93', '%d/%m/%y'), nationality: 'Argentina', weight: 78, height: 1.83, team: san_lorenzo)
Player.create!(first_name: 'Nestor', last_name: 'Ortigoza', position: 'midfielder', description: '-', birthday: DateTime.strptime('7/10/84', '%d/%m/%y'), nationality: 'Paraguay', weight: 70, height: 1.76, team: san_lorenzo)
Player.create!(first_name: 'Rodrigo', last_name: 'Contreras', position: 'forward', description: '-', birthday: DateTime.strptime('27/10/95', '%d/%m/%y'), nationality: 'Argentina', weight: 75, height: 1.83, team: san_lorenzo)
Player.create!(first_name: 'Gabriel', last_name: 'Esparza', position: 'forward', description: '-', birthday: DateTime.strptime('30/1/93', '%d/%m/%y'), nationality: 'Argentina', weight: 69, height: 1.68, team: san_lorenzo)

## BAJAS
luciano_monzon = Player.find_by(first_name: 'Luciano', last_name: 'Monzon', team: boca).update_attributes(team: nil)
franco_cristialdo = Player.find_by(first_name: 'Franco', last_name: 'Cristaldo', team: boca).update_attributes(team: nil)
juan_komar = Player.find_by(first_name: 'Juan Cruz', last_name: 'Komar', team: boca).update_attributes(team: nil)
german_montoya = Player.find_by(first_name: 'German', last_name: 'Montoya', team: independiente).update_attributes(team: nil)
matias_catalan = Player.find_by(first_name: 'Matias', last_name: 'Catalan', team: san_lorenzo).update_attributes(team: nil)
brian_luciatti = Player.find_by(first_name: 'Brian', last_name: 'Luciatti', team: san_lorenzo).update_attributes(team: nil)

## NUEVAS MESAS
est_rac = Match.find_by(title: 'Estudiantes LP vs Racing')
slo_hur = Match.find_by(title: 'San Lorenzo vs Huracan')

racing_estudiantes = Table.create!(title: 'Estudiantes LP vs Racing', matches: [est_rac], start_time: est_rac.datetime, end_time: est_rac.datetime + 1.day, tournament: Tournament.last, number_of_players: 3, points_for_winners: PointsForWinners.default, description: '-', table_rules: TableRules.create)
san_lorenzo_huracan = Table.create!(title: 'San Lorenzo vs Huracan', matches: [slo_hur], start_time: slo_hur.datetime, end_time: slo_hur.datetime + 1.day, tournament: Tournament.last, number_of_players: 3, points_for_winners: PointsForWinners.default, description: '-', table_rules: TableRules.create)
mesa_mixta = Table.create!(title: 'Mesa Mixta', matches: [est_rac, slo_hur], start_time: est_rac.datetime, end_time: slo_hur.datetime + 1.day, tournament: Tournament.last, number_of_players: 5, points_for_winners: PointsForWinners.default, description: '-', table_rules: TableRules.create)