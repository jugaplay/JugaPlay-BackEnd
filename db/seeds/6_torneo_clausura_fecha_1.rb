ActiveRecord::Base.transaction do
  torneo = Tournament.find_by(name: 'Primera A Argentina 2016')

  gimnasia = Team.find_by!(name: 'Gimnasia LP')
  estudiantes = Team.find_by!(name: 'Estudiantes LP')
  huracan = Team.find_by!(name: 'Huracan')
  river = Team.find_by!(name: 'River Plate')
  boca = Team.find_by!(name: 'Boca Juniors')
  san_lorenzo = Team.find_by!(name: 'San Lorenzo')
  racing = Team.find_by!(name: 'Racing')
  independiente = Team.find_by!(name: 'Independiente')
  aldosivi = Team.find_by!(name: 'Aldosivi')
  arsenal = Team.find_by!(name: 'Arsenal')
  atl_tucuman = Team.find_by!(name: 'Atlético Tucumán')
  atl_rafaela = Team.find_by!(name: 'Atlético Rafaela')
  banfield = Team.find_by!(name: 'Banfield')
  belgrano = Team.find_by!(name: 'Belgrano')
  colon = Team.find_by!(name: 'Colón')
  def_justicia = Team.find_by!(name: 'Defensa y Justicia')
  godoy_cruz = Team.find_by!(name: 'Godoy Cruz')
  lanus = Team.find_by!(name: 'Lanús')
  newells = Team.find_by!(name: "Newell's Old Boys")
  olimpo = Team.find_by!(name: 'Olimpo')
  patronato = Team.find_by!(name: 'Patronato')
  quilmes = Team.find_by!(name: 'Quilmes')
  rosario = Team.find_by!(name: 'Rosario Central')
  san_martin_sj = Team.find_by!(name: 'San Martín (SJ)')
  sarmiento = Team.find_by!(name: 'Sarmiento')
  temperley = Team.find_by!(name: 'Temperley')
  tigre = Team.find_by!(name: 'Tigre')
  velez = Team.find_by!(name: 'Vélez')
  union = Team.find_by!(name: 'Unión')
  argentinos = Team.find_by!(name: 'Argentinos Juniors')

  Match.create!(local_team: banfield, visitor_team: gimnasia, tournament: torneo, datetime: DateTime.strptime('5/2/16 19:00', '%d/%m/%y %H:%M'), title: 'F1 Banfield vs Gimnsaia')
  Match.create!(local_team: huracan, visitor_team: atl_rafaela, tournament: torneo, datetime: DateTime.strptime('5/2/16 19:00', '%d/%m/%y %H:%M'), title: 'F1 Huracan vs Atlético Rafaela')
  Match.create!(local_team: rosario, visitor_team: godoy_cruz, tournament: torneo, datetime: DateTime.strptime('5/2/16 21:15', '%d/%m/%y %H:%M'), title: 'F1 Rosario Central vs Godoy Cruz')
  Match.create!(local_team: aldosivi, visitor_team: olimpo, tournament: torneo, datetime: DateTime.strptime('6/2/16 17:00', '%d/%m/%y %H:%M'), title: 'F1 Aldosivi vs Olimpo')
  Match.create!(local_team: argentinos, visitor_team: tigre, tournament: torneo, datetime: DateTime.strptime('6/2/16 17:00', '%d/%m/%y %H:%M'), title: 'F1 Argentinos vs Tigre')
  Match.create!(local_team: patronato, visitor_team: san_lorenzo, tournament: torneo, datetime: DateTime.strptime('6/2/16 19:00', '%d/%m/%y %H:%M'), title: 'F1 Patronato vs San Lorenzo')
  Match.create!(local_team: san_martin_sj, visitor_team: newells, tournament: torneo, datetime: DateTime.strptime('6/2/16 19:15', '%d/%m/%y %H:%M'), title: 'F1 San Martin vs Newlls')
  Match.create!(local_team: temperley, visitor_team: boca, tournament: torneo, datetime: DateTime.strptime('6/2/16 21:00', '%d/%m/%y %H:%M'), title: 'F1 Temperley vs Boca')
  Match.create!(local_team: independiente, visitor_team: belgrano, tournament: torneo, datetime: DateTime.strptime('7/2/16 17:00', '%d/%m/%y %H:%M'), title: 'F1 Independiente vs Belgrano')
  Match.create!(local_team: def_justicia, visitor_team: union, tournament: torneo, datetime: DateTime.strptime('7/2/16 17:00', '%d/%m/%y %H:%M'), title: 'F1 Def just vs Union')
  Match.create!(local_team: river, visitor_team: quilmes, tournament: torneo, datetime: DateTime.strptime('7/2/16 19:00', '%d/%m/%y %H:%M'), title: 'F1 River vs Quilmes')
  Match.create!(local_team: colon, visitor_team: arsenal, tournament: torneo, datetime: DateTime.strptime('7/2/16 19:15', '%d/%m/%y %H:%M'), title: 'F1 Colon vs Arsenal')
  Match.create!(local_team: atl_tucuman, visitor_team: racing, tournament: torneo, datetime: DateTime.strptime('7/2/16 21:00', '%d/%m/%y %H:%M'), title: 'F1 Atl Tucuman vs Racing')
  Match.create!(local_team: estudiantes, visitor_team: lanus, tournament: torneo, datetime: DateTime.strptime('8/2/16 19:00', '%d/%m/%y %H:%M'), title: 'F1 Estudiantes vs Lanus')
  Match.create!(local_team: sarmiento, visitor_team: velez, tournament: torneo, datetime: DateTime.strptime('8/2/16 21:15', '%d/%m/%y %H:%M'), title: 'F1 Sarmiento vs Vélez')
end
