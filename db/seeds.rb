ActiveRecord::Base.transaction do
  torneo_verano = Tournament.create!(name: 'Torneo de Verano')

   ## USER WALLET  
	wallet =  Wallet.new(coins: 10, credits: 0)
  	
  ## ADMIN
  admin = User.new(wallet: wallet, email: 'admin@jugaplay.com', password: '12345678', first_name: 'Admin', last_name: 'Admin', nickname: 'Admin')
  admin.save!
     
  
  ## INDEPENDIENTE
  independiente_director = Director.create!(first_name: 'Mauricio', last_name: 'Pellegrino', description: '-')
  independiente_players = Player.create!([
    { first_name: 'Diego', last_name: 'Rodriguez', position: 'goalkeeper', description: '-', birthday: Date.strptime('25/6/89', '%d/%m/%y'), nationality: 'Argentina', weight: 80, height: 1.84 },
    { first_name: 'Gustavo', last_name: 'Toledo', position: 'defender', description: '-', birthday: Date.strptime('19/9/89', '%d/%m/%y'), nationality: 'Argentina', weight: 72, height: 1.71 },
    { first_name: 'Hernan', last_name: 'Pellerano', position: 'defender', description: '-', birthday: Date.strptime('4/6/84', '%d/%m/%y'), nationality: 'Argentina', weight: 72, height: 1.83 },
    { first_name: 'Victor', last_name: 'Cuesta', position: 'defender', description: '-', birthday: Date.strptime('19/11/88', '%d/%m/%y'), nationality: 'Argentina', weight: 74, height: 1.75 },
    { first_name: 'Nicolas', last_name: 'Tagliafico', position: 'defender', description: '-', birthday: Date.strptime('31/8/92', '%d/%m/%y'), nationality: 'Argentina', weight: 63, height: 1.67 },
    { first_name: 'Jorge', last_name: 'Ortiz', position: 'midfielder', description: '-', birthday: Date.strptime('20/6/84', '%d/%m/%y'), nationality: 'Argentina', weight: 71, height: 1.76 },
    { first_name: 'Jesus', last_name: 'Mendez', position: 'midfielder', description: '-', birthday: Date.strptime('1/8/84', '%d/%m/%y'), nationality: 'Argentina', weight: 78, height: 1.79 },
    { first_name: 'Diego', last_name: 'Rodriguez Berrini', position: 'midfielder', description: '-', birthday: Date.strptime('8/8/86', '%d/%m/%y'), nationality: 'Uruguay', weight: 72, height: 1.76 },
    { first_name: 'Rodrigo', last_name: 'Gomez', position: 'midfielder', description: '-', birthday: Date.strptime('2/1/93', '%d/%m/%y'), nationality: 'Argentina', weight: 65, height: 1.68 },
    { first_name: 'Cristian', last_name: 'Rodriguez', position: 'midfielder', description: '-', birthday: Date.strptime('30/9/85', '%d/%m/%y'), nationality: 'Argentina', weight: 72, height: 1.75 },
    { first_name: 'Martin', last_name: 'Benitez', position: 'forward', description: '-', birthday: Date.strptime('17/6/94', '%d/%m/%y'), nationality: 'Argentina', weight: 71, height: 1.73 },
    { first_name: 'Diego', last_name: 'Vera', position: 'forward', description: '-', birthday: Date.strptime('5/1/85', '%d/%m/%y'), nationality: 'Uruguay', weight: 74, height: 1.81 },
    { first_name: 'German', last_name: 'Montoya', position: 'goalkeeper', description: '-', birthday: Date.strptime('23/1/83', '%d/%m/%y'), nationality: 'Argentina', weight: 71, height: 1.72 },
    { first_name: 'Emiliano', last_name: 'Papa', position: 'defender', description: '-', birthday: Date.strptime('19/4/82', '%d/%m/%y'), nationality: 'Argentina', weight: 67, height: 1.69 },
    { first_name: 'Marcos', last_name: 'Caceres', position: 'defender', description: '-', birthday: Date.strptime('5/5/86', '%d/%m/%y'), nationality: 'Paraguay', weight: 79, height: 1.84 },
    { first_name: 'Juan', last_name: 'Martinez Trejo', position: 'midfielder', description: '-', birthday: Date.strptime('12/1/92', '%d/%m/%y'), nationality: 'Argentina', weight: 65, height: 1.85 },
    { first_name: 'Claudio', last_name: 'Aquino', position: 'forward', description: '-', birthday: Date.strptime('24/7/91', '%d/%m/%y'), nationality: 'Argentina', weight: 70, height: 1.72 },
    { first_name: 'Julian', last_name: 'Vitale', position: 'midfielder', description: '-', birthday: Date.strptime('21/7/95', '%d/%m/%y'), nationality: 'Argentina', weight: 76, height: 1.82 },
  ])
  independiente = Team.create!(name: 'Independiente', director: independiente_director, players: independiente_players, description: 'El Rojo', short_name: 'IND')
  
  
  ## RACING
  racing_director = Director.create!(first_name: 'Facundo', last_name: 'Sava', description: '-')
  racing_players = Player.create!([
    { first_name: 'Sebastian', last_name: 'Saja', position: 'goalkeeper', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 },
    { first_name: 'Ivan', last_name: 'Pillud', position: 'defender', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Luciano', last_name: 'Lollo', position: 'defender', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Nicolas', last_name: 'Sanchez', position: 'defender', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Leandro', last_name: 'Grimi', position: 'defender', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Gaston', last_name: 'Diaz', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Francisco', last_name: 'Cerro', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Luciano', last_name: 'Aued', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Marcos', last_name: 'Acuna', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Oscar', last_name: 'Romero', position: 'forward', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Gustavo', last_name: 'Bou', position: 'forward', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Nelson', last_name: 'Ibanez', position: 'goalkeeper', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Yonathan', last_name: 'Cabral', position: 'defender', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'German', last_name: 'Voboril', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Washington', last_name: 'Camacho', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Ricardo', last_name: 'Noir', position: 'forward', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Carlos', last_name: 'Nunez', position: 'midfielder', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }, 
    { first_name: 'Mariano', last_name: 'Pavone', position: 'forward', description: '-', birthday: Date.today, nationality: 'Argentina', weight: 2, height: 1 }
  ])
  racing = Team.create!(name: 'Racing', director: racing_director, players: racing_players, description: 'La Academia', short_name: 'RAC')
  
  
  ## SAN LORENZO
  sanlorenzo_director = Director.create!(first_name: 'Pablo', last_name: 'Gaude', description: '-')
  san_lorenzo_players = Player.create!([
    { first_name: 'Sebastian', last_name: 'Torrico', position: 'goalkeeper', description: '-', birthday: Date.strptime('22/2/80', '%d/%m/%y'), nationality: 'Argentina', weight: 84, height: 1.86 },
    { first_name: 'Julio', last_name: 'Buffarini', position: 'defender', description: '-', birthday: Date.strptime('18/8/88', '%d/%m/%y'), nationality: 'Argentina', weight: 70, height: 1.80 },
    { first_name: 'Matias', last_name: 'Caruzzo', position: 'defender', description: '-', birthday: Date.strptime('15/8/84', '%d/%m/%y'), nationality: 'Argentina', weight: 76, height: 1.82 },
    { first_name: 'Fernando', last_name: 'Meza', position: 'defender', description: '-', birthday: Date.strptime('21/3/90', '%d/%m/%y'), nationality: 'Argentina', weight: 64, height: 1.76 },
    { first_name: 'Emanuel', last_name: 'Mas', position: 'defender', description: '-', birthday: Date.strptime('15/1/89', '%d/%m/%y'), nationality: 'Argentina', weight: 73, height: 1.83 },
    { first_name: 'Juan', last_name: 'Mercier', position: 'midfielder', description: '-', birthday: Date.strptime('2/2/80', '%d/%m/%y'), nationality: 'Argentina', weight: 78, height: 1.81 },
    { first_name: 'Enzo', last_name: 'Kalinski', position: 'midfielder', description: '-', birthday: Date.strptime('10/3/87', '%d/%m/%y'), nationality: 'Argentina', weight: 71, height: 1.70 },
    { first_name: 'Hector', last_name: 'Villalba', position: 'forward', description: '-', birthday: Date.strptime('27/6/94', '%d/%m/%y'), nationality: 'Argentina', weight: 73, height: 1.72 },
    { first_name: 'Sebastian', last_name: 'Blanco', position: 'midfielder', description: '-', birthday: Date.strptime('15/3/88', '%d/%m/%y'), nationality: 'Argentina', weight: 64, height: 1.66 },
    { first_name: 'Pablo', last_name: 'Barrientos', position: 'midfielder', description: '-', birthday: Date.strptime('17/1/85', '%d/%m/%y'), nationality: 'Argentina', weight: 66, height: 1.76 },
    { first_name: 'Martin', last_name: 'Cauteruccio', position: 'goalkeeper', description: '-', birthday: Date.strptime('14/4/87', '%d/%m/%y'), nationality: 'Uruguay', weight: 76, height: 1.75 },
    { first_name: 'Jose', last_name: 'Devecchi', position: 'goalkeeper', description: '-', birthday: Date.strptime('1/9/95', '%d/%m/%y'), nationality: 'Argentina', weight: 81, height: 1.91 },
    { first_name: 'Matias', last_name: 'Catalan', position: 'defender', description: '-', birthday: Date.strptime('19/8/92', '%d/%m/%y'), nationality: 'Argentina', weight: 79, height: 1.82 },
    { first_name: 'Brian', last_name: 'Luciatti', position: 'defender', description: '-', birthday: Date.strptime('18/3/93', '%d/%m/%y'), nationality: 'Argentina', weight: 66, height: 1.70 },
    { first_name: 'Alejandro', last_name: 'Melo', position: 'midfielder', description: '-', birthday: Date.strptime('11/1/96', '%d/%m/%y'), nationality: 'Argentina', weight: 70, height: 1.80 },
    { first_name: 'Gonzalo', last_name: 'Prosperi', position: 'defender', description: '-', birthday: Date.strptime('3/6/85', '%d/%m/%y'), nationality: 'Argentina', weight: 78, height: 1.79 },
    { first_name: 'Franco', last_name: 'Mussis', position: 'midfielder', description: '-', birthday: Date.strptime('19/4/92', '%d/%m/%y'), nationality: 'Argentina', weight: 65, height: 1.74 },
    { first_name: 'Martin', last_name: 'Rolle', position: 'forward', description: '-', birthday: Date.strptime('25/5/85', '%d/%m/%y'), nationality: 'Argentina', weight: 65, height: 1.65 },
    { first_name: 'Nicolas', last_name: 'Blandi', position: 'forward', description: '-', birthday: Date.strptime('31/1/90', '%d/%m/%y'), nationality: 'Argentina', weight: 78, height: 1.81 },
    { first_name: 'Mauro', last_name: 'Matos', position: 'forward', description: '-', birthday: Date.strptime('6/8/82', '%d/%m/%y'), nationality: 'Argentina', weight: 80, height: 1.80 },
  ])
  san_lorenzo = Team.create!(name: 'San Lorenzo', director: sanlorenzo_director, players: san_lorenzo_players, description: 'El Ciclon', short_name: 'SLO')
  
  
  ## BOCA
  boca_director = Director.create!(first_name: 'Rodolfo', last_name: 'Arruabarrena', description: '-')
  boca_players = Player.create!([
    { first_name: 'Agustin', last_name: 'Orion', position: 'goalkeeper', description: '-', birthday: Date.strptime('26/7/81', '%d/%m/%y'), nationality: 'Argentina', weight: '83', height: '1.90' },
    { first_name: 'Gino', last_name: 'Peruzzi', position: 'defender', description: '-', birthday: Date.strptime('9/6/92', '%d/%m/%y'), nationality: 'Argentina', weight: '69', height: '1.78' },
    { first_name: 'Fernando', last_name: 'Tobio', position: 'defender', description: '-', birthday: Date.strptime('18/10/89', '%d/%m/%y'), nationality: 'Argentina', weight: '85', height: '1.85' },
    { first_name: 'Daniel', last_name: 'Diaz', position: 'defender', description: '-', birthday: Date.strptime('13/7/79', '%d/%m/%y'), nationality: 'Argentina', weight: '74', height: '1.80' },
    { first_name: 'Luciano', last_name: 'Monzon', position: 'defender', description: '-', birthday: Date.strptime('13/4/87', '%d/%m/%y'), nationality: 'Argentina', weight: '75', height: '1.79' },
    { first_name: 'Rodrigo', last_name: 'Bentancur', position: 'defender', description: '-', birthday: Date.strptime('5/6/97', '%d/%m/%y'), nationality: 'Uruguay', weight: '73', height: '1.78' },
    { first_name: 'Cristian', last_name: 'Erbes', position: 'midfielder', description: '-', birthday: Date.strptime('6/1/90', '%d/%m/%y'), nationality: 'Argentina', weight: '72', height: '1.72' },
    { first_name: 'Nicolas', last_name: 'Colazo', position: 'defender', description: '-', birthday: Date.strptime('8/7/90', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.78' },
    { first_name: 'Nicolas', last_name: 'Lodeiro', position: 'midfielder', description: '-', birthday: Date.strptime('21/3/89', '%d/%m/%y'), nationality: 'Uruguay', weight: '69', height: '1.73' },
    { first_name: 'Carlos', last_name: 'Tevez', position: 'forward', description: '-', birthday: Date.strptime('5/2/84', '%d/%m/%y'), nationality: 'Argentina', weight: '73', height: '1.73' },
    { first_name: 'Guillermo', last_name: 'Sara', position: 'goalkeeper', description: '-', birthday: Date.strptime('30/9/87', '%d/%m/%y'), nationality: 'Argentina', weight: '78', height: '1.88' },
    { first_name: 'Alexis', last_name: 'Rolin', position: 'defender', description: '-', birthday: Date.strptime('7/2/89', '%d/%m/%y'), nationality: 'Uruguay', weight: '76', height: '1.86' },
    { first_name: 'Andres', last_name: 'Cubas', position: 'midfielder', description: '-', birthday: Date.strptime('22/5/96', '%d/%m/%y'), nationality: 'Argentina', weight: '60', height: '1.63' },
    { first_name: 'Franco', last_name: 'Cristaldo', position: 'midfielder', description: '-', birthday: Date.strptime('15/8/96', '%d/%m/%y'), nationality: 'Argentina', weight: '70', height: '1.70' },
    { first_name: 'Sebastian', last_name: 'Palacios', position: 'forward', description: '-', birthday: Date.strptime('20/1/92', '%d/%m/%y'), nationality: 'Argentina', weight: '63', height: '1.63' },
    { first_name: 'Andres', last_name: 'Chavez', position: 'forward', description: '-', birthday: Date.strptime('21/3/91', '%d/%m/%y'), nationality: 'Argentina', weight: '82', height: '1.84' },
    { first_name: 'Pablo', last_name: 'Perez', position: 'midfielder', description: '-', birthday: Date.strptime('10/8/85', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.79' },
    { first_name: 'Juan Cruz', last_name: 'Komar', position: 'defender', description: '-', birthday: Date.strptime('13/8/96', '%d/%m/%y'), nationality: 'Argentina', weight: '78', height: '1.83' },
    { first_name: 'Lisandro', last_name: 'Magallan', position: 'defender', description: '-', birthday: Date.strptime('27/9/93', '%d/%m/%y'), nationality: 'Argentina', weight: '79', height: '1.82' },
    { first_name: 'Leonardo', last_name: 'Jara', position: 'defender', description: '-', birthday: Date.strptime('20/5/91', '%d/%m/%y'), nationality: 'Argentina', weight: '80', height: '1.83' },
    { first_name: 'Jonathan', last_name: 'Silva', position: 'defender', description: '-', birthday: Date.strptime('29/6/94', '%d/%m/%y'), nationality: 'Argentina', weight: '69', height: '1.78' },
    { first_name: 'Daniel', last_name: 'Osvaldo', position: 'forward', description: '-', birthday: Date.strptime('12/1/86', '%d/%m/%y'), nationality: 'Argentina', weight: '81', height: '1.82' },
  ])
  boca = Team.create!(name: 'Boca Juniors', director: boca_director, players: boca_players, description: 'Xeneizes', short_name: 'BOC')
  
  
  ## RIVER
  river_director = Director.create!(first_name: 'Marcelo', last_name: 'Gallardo', description: '-')
  river_players =  Player.create!([
    { first_name: 'Marcelo', last_name: 'Barovero', position: 'goalkeeper', description: '-', birthday: Date.strptime('18/2/84', '%d/%m/%y'), nationality: 'Argentina', weight: '74', height: '1.82' },
    { first_name: 'Jonatan', last_name: 'Maidana', position: 'defender', description: '-', birthday: Date.strptime('29/7/85', '%d/%m/%y'), nationality: 'Argentina', weight: '86', height: '1.83' },
    { first_name: 'Gabriel', last_name: 'Mercado', position: 'defender', description: '-', birthday: Date.strptime('18/3/87', '%d/%m/%y'), nationality: 'Argentina', weight: '85', height: '1.81' },
    { first_name: 'Tabare', last_name: 'Viudez', position: 'forward', description: '-', birthday: Date.strptime('8/9/89', '%d/%m/%y'), nationality: 'Uruguay', weight: '64', height: '1.69' },
    { first_name: 'Eder', last_name: 'Alvarez Balanta', position: 'defender', description: '-', birthday: Date.strptime('28/2/93', '%d/%m/%y'), nationality: 'Colombia', weight: '84', height: '1.81' },
    { first_name: 'Rodrigo', last_name: 'Mora', position: 'forward', description: '-', birthday: Date.strptime('29/10/87', '%d/%m/%y'), nationality: 'Uruguay', weight: '72', height: '1.72' },
    { first_name: 'Carlos', last_name: 'Sanchez', position: 'midfielder', description: '-', birthday: Date.strptime('2/12/84', '%d/%m/%y'), nationality: 'Uruguay', weight: '72', height: '1.70' },
    { first_name: 'Lucas', last_name: 'Alario', position: 'forward', description: '-', birthday: Date.strptime('8/10/92', '%d/%m/%y'), nationality: 'Argentina', weight: '68', height: '1.80' },
    { first_name: 'Leonel', last_name: 'Vangioni', position: 'defender', description: '-', birthday: Date.strptime('5/5/87', '%d/%m/%y'), nationality: 'Argentina', weight: '80', height: '1.81' },
    { first_name: 'Leonardo', last_name: 'Ponzio', position: 'midfielder', description: '-', birthday: Date.strptime('29/1/83', '%d/%m/%y'), nationality: 'Argentina', weight: '75', height: '1.75' },
    { first_name: 'Emanuel', last_name: 'Mammana', position: 'defender', description: '-', birthday: Date.strptime('10/2/96', '%d/%m/%y'), nationality: 'Argentina', weight: '69', height: '1.80' },
    { first_name: 'Milton', last_name: 'Casco', position: 'defender', description: '-', birthday: Date.strptime('11/4/88', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.69' },
    { first_name: 'Gonzalo', last_name: 'Martinez', position: 'midfielder', description: '-', birthday: Date.strptime('13/6/93', '%d/%m/%y'), nationality: 'Argentina', weight: '67', height: '1.70' },
    { first_name: 'Julio', last_name: 'Chiarini', position: 'goalkeeper', description: '-', birthday: Date.strptime('4/3/82', '%d/%m/%y'), nationality: 'Argentina', weight: '75', height: '1.85' },
    { first_name: 'Camilo', last_name: 'Mayada', position: 'defender', description: '-', birthday: Date.strptime('8/1/91', '%d/%m/%y'), nationality: 'Uruguay', weight: '70', height: '1.70' },
    { first_name: 'Luis', last_name: 'Gonzales', position: 'midfielder', description: '-', birthday: Date.strptime('19/1/81', '%d/%m/%y'), nationality: 'Argentina', weight: '72', height: '1.85' },
    { first_name: 'Leonardo', last_name: 'Pisculichi', position: 'midfielder', description: '-', birthday: Date.strptime('18/1/84', '%d/%m/%y'), nationality: 'Argentina', weight: '77', height: '1.78' },
    { first_name: 'Javier', last_name: 'Saviola', position: 'forward', description: '-', birthday: Date.strptime('11/12/81', '%d/%m/%y'), nationality: 'Argentina', weight: '62', height: '1.68' },
    { first_name: 'Nicolas', last_name: 'Domingo', position: 'midfielder', description: '-', birthday: Date.strptime('8/4/85', '%d/%m/%y'), nationality: 'Argentina', weight: '73', height: '1.74' },
    { first_name: 'Joaquin', last_name: 'Arzura', position: 'midfielder', description: '-', birthday: Date.strptime('18/5/93', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.70' },
    { first_name: 'Sebastian', last_name: 'Driussi', position: 'midfielder', description: '-', birthday: Date.strptime('9/2/96', '%d/%m/%y'), nationality: 'Argentina', weight: '77', height: '1.77' }
  ])
  river = Team.create!(name: 'River Plate', director: river_director, players: river_players, description: 'Millonarios', short_name: 'RIV')
  
  
  ## HURACAN
  huracan_director = Director.create!(first_name: 'Eduardo', last_name: 'Dominguez', description: '-')
  huracan_players = Player.create!([
    { first_name: 'Marcos', last_name: 'Diaz', position: 'goalkeeper', description: '-', birthday: Date.strptime('5/2/86', '%d/%m/%y'), nationality: 'Argentina', weight: '84', height: '1.87' },
    { first_name: 'Jose', last_name: 'San Roman', position: 'defender', description: '-', birthday: Date.strptime('17/8/88', '%d/%m/%y'), nationality: 'Argentina', weight: '70', height: '1.71' },
    { first_name: 'Hugo', last_name: 'Nervo', position: 'defender', description: '-', birthday: Date.strptime('6/1/91', '%d/%m/%y'), nationality: 'Argentina', weight: '72', height: '1.83' },
    { first_name: 'Luciano', last_name: 'Balbi', position: 'defender', description: '-', birthday: Date.strptime('12/4/89', '%d/%m/%y'), nationality: 'Argentina', weight: '72', height: '1.72' },
    { first_name: 'Mauro', last_name: 'Bogado', position: 'midfielder', description: '-', birthday: Date.strptime('31/5/85', '%d/%m/%y'), nationality: 'Argentina', weight: '68', height: '1.70' },
    { first_name: 'Cristian', last_name: 'Espinoza', position: 'forward', description: '-', birthday: Date.strptime('3/4/95', '%d/%m/%y'), nationality: 'Argentina', weight: '70', height: '1.72' },
    { first_name: 'Ivan', last_name: 'Moreno y Fabianesi', position: 'midfielder', description: '-', birthday: Date.strptime('1/6/79', '%d/%m/%y'), nationality: 'España', weight: '73', height: '1.75' },
    { first_name: 'Patricio', last_name: 'Toranzo', position: 'forward', description: '-', birthday: Date.strptime('19/3/82', '%d/%m/%y'), nationality: 'Argentina', weight: '73', height: '1.78' },
    { first_name: 'Ramon', last_name: 'Abila', position: 'forward', description: '-', birthday: Date.strptime('14/10/89', '%d/%m/%y'), nationality: 'Argentina', weight: '65', height: '1.78' },
    { first_name: 'Matias', last_name: 'Giordano', position: 'goalkeeper', description: '-', birthday: Date.strptime('11/9/79', '%d/%m/%y'), nationality: 'Argentina', weight: '87', height: '1.89' },
    { first_name: 'Mario', last_name: 'Risso', position: 'defender', description: '-', birthday: Date.strptime('31/1/88', '%d/%m/%y'), nationality: 'Uruguay', weight: '84', height: '1.92' },
    { first_name: 'Lucas', last_name: 'Villarruel', position: 'midfielder', description: '-', birthday: Date.strptime('13/10/90', '%d/%m/%y'), nationality: 'Argentina', weight: '74', height: '1.73' },
    { first_name: 'Daniel', last_name: 'Montenegro', position: 'midfielder', description: '-', birthday: Date.strptime('28/3/79', '%d/%m/%y'), nationality: 'Argentina', weight: '76', height: '1.72' },
    { first_name: 'German', last_name: 'Mandarino', position: 'midfielder', description: '-', birthday: Date.strptime('13/12/84', '%d/%m/%y'), nationality: 'Argentina', weight: '74', height: '1.79' },
    { first_name: 'Ezequiel', last_name: 'Miralles', position: 'forward', description: '-', birthday: Date.strptime('21/7/83', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.76' }
  ])
  huracan = Team.create!(name: 'Huracan', director: huracan_director, players: huracan_players, description: 'El Globo', short_name: 'HUR')
  
  
  ## ESTUDIANTES
  estudiantes_director = Director.create!(first_name: 'Nelson', last_name: 'Vivas', description: '-')
  estudiantes_players = Player.create!([
    { first_name: 'Agustin', last_name: 'Silva', position: 'goalkeeper', description: '-', birthday: Date.strptime('28/6/89', '%d/%m/%y'), nationality: 'Argentina', weight: '92', height: '1.90' },
    { first_name: 'Lucas', last_name: 'Viatri', position: 'forward', description: '-', birthday: Date.strptime('29/3/87', '%d/%m/%y'), nationality: 'Argentina', weight: '82', height: '1.85' },
    { first_name: 'Jonathan', last_name: 'Schunke', position: 'defender', description: '-', birthday: Date.strptime('22/2/87', '%d/%m/%y'), nationality: 'Argentina', weight: '84', height: '1.91' },
    { first_name: 'Leonardo', last_name: 'Desabato', position: 'defender', description: '-', birthday: Date.strptime('24/1/79', '%d/%m/%y'), nationality: 'Argentina', weight: '87', height: '1.87' },
    { first_name: 'Alvaro', last_name: 'Pereira', position: 'defender', description: '-', birthday: Date.strptime('28/11/85', '%d/%m/%y'), nationality: 'Uruguay', weight: '78', height: '1.80' },
    { first_name: 'Leonardo', last_name: 'Gil', position: 'midfielder', description: '-', birthday: Date.strptime('31/5/91', '%d/%m/%y'), nationality: 'Argentina', weight: '65', height: '1.76' },
    { first_name: 'Israel', last_name: 'Damonte', position: 'midfielder', description: '-', birthday: Date.strptime('6/1/82r', '%d/%m/%y'), nationality: 'Argentina', weight: '72', height: '1.76' },
    { first_name: 'Carlos', last_name: 'Auzqui', position: 'forward', description: '-', birthday: Date.strptime('16/3/91', '%d/%m/%y'), nationality: 'Argentina', weight: '68', height: '1.74' },
    { first_name: 'Facundo', last_name: 'Sanchez', position: 'midfielder', description: '-', birthday: Date.strptime('7/3/90', '%d/%m/%y'), nationality: 'Argentina', weight: '73', height: '1.75' },
    { first_name: 'Gonzalo', last_name: 'Bueno', position: 'forward', description: '-', birthday: Date.strptime('16/1/93', '%d/%m/%y'), nationality: 'Uruguay', weight: '74', height: '1.76' },
    { first_name: 'Gaston', last_name: 'Fernandez', position: 'forward', description: '-', birthday: Date.strptime('12/10/83', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.70' },
    { first_name: 'Agustin', last_name: 'Rossi', position: 'goalkeeper', description: '-', birthday: Date.strptime('21/8/95', '%d/%m/%y'), nationality: 'Argentina', weight: '85', height: '1.95' },
    { first_name: 'Mauricio', last_name: 'Rosales', position: 'defender', description: '-', birthday: Date.strptime('10/03/92', '%d/%m/%y'), nationality: 'Argentina', weight: '68', height: '1.74' },
    { first_name: 'Augusto', last_name: 'Solari', position: 'defender', description: '-', birthday: Date.strptime('3/1/92', '%d/%m/%y'), nationality: 'Argentina', weight: '69', height: '1.78' },
    { first_name: 'Gaston', last_name: 'Gil Romero', position: 'midfielder', description: '-', birthday: Date.strptime('6/5/93', '%d/%m/%y'), nationality: 'Argentina', weight: '79', height: '1.77' },
    { first_name: 'David', last_name: 'Barbona', position: 'midfielder', description: '-', birthday: Date.strptime('22/2/95', '%d/%m/%y'), nationality: 'Argentina', weight: '81', height: '1.79' },
    { first_name: 'Diego', last_name: 'Mendoza', position: 'forward', description: '-', birthday: Date.strptime('30/9/92', '%d/%m/%y'), nationality: 'Argentina', weight: '85', height: '1.86' },
    { first_name: 'Emiliano', last_name: 'Ozuna', position: 'midfielder', description: '-', birthday: Date.strptime('9/2/96', '%d/%m/%y'), nationality: 'Argentina', weight: '60', height: '1.66' }
  ])
  estudiantes = Team.create!(name: 'Estudiantes LP', director: estudiantes_director, players: estudiantes_players, description: 'El Pincha', short_name: 'EST')
  
  
  ## GIMNASIA
  gimnasia_director = Director.create!(first_name: 'Pedro', last_name: 'Troglio', description: '-')
  gimnasia_players = Player.create!([
    { first_name: 'Yair', last_name: 'Bonnin', position: 'goalkeeper', description: '-', birthday: Date.strptime('20/9/90', '%d/%m/%y'), nationality: 'Argentina', weight: '83', height: '1.87' },
    { first_name: 'Facundo', last_name: 'Oreja', position: 'defender', description: '-', birthday: Date.strptime('14/6/82', '%d/%m/%y'), nationality: 'Argentina', weight: '73', height: '1.69' },
    { first_name: 'Maximiliano', last_name: 'Coronel', position: 'defender', description: '-', birthday: Date.strptime('28/4/89', '%d/%m/%y'), nationality: 'Argentina', weight: '80', height: '1.80' },
    { first_name: 'Oliver', last_name: 'Benitez', position: 'defender', description: '-', birthday: Date.strptime('7/6/91', '%d/%m/%y'), nationality: 'Argentina', weight: '80', height: '1.86' },
    { first_name: 'Lucas', last_name: 'Licht', position: 'defender', description: '-', birthday: Date.strptime('6/4/81', '%d/%m/%y'), nationality: 'Argentina', weight: '72', height: '1.74' },
    { first_name: 'Jorge', last_name: 'Rojas', position: 'midfielder', description: '-', birthday: Date.strptime('7/1/93', '%d/%m/%y'), nationality: 'Paraguay', weight: '66', height: '1.68' },
    { first_name: 'Omar ', last_name: 'Pouso', position: 'midfielder', description: '-', birthday: Date.strptime('28/2/80', '%d/%m/%y'), nationality: 'Uruguay', weight: '74', height: '1.80' },
    { first_name: 'Roberto', last_name: 'Brum', position: 'midfielder', description: '-', birthday: Date.strptime('5/7/83', '%d/%m/%y'), nationality: 'Uruguay', weight: '74', height: '1.74' },
    { first_name: 'Ignacio', last_name: 'Fernandez', position: 'midfielder', description: '-', birthday: Date.strptime('12/1/90', '%d/%m/%y'), nationality: 'Argentina', weight: '70', height: '1.82' },
    { first_name: 'Antonio', last_name: 'Medina', position: 'forward', description: '-', birthday: Date.strptime('18/12/84', '%d/%m/%y'), nationality: 'Argentina', weight: '65', height: '1.70' },
    { first_name: 'Javier', last_name: 'Mendoza', position: 'midfielder', description: '-', birthday: Date.strptime('2/9/92', '%d/%m/%y'), nationality: 'Argentina', weight: '65', height: '1.71' },
    { first_name: 'Alexis Martin', last_name: 'Arias', position: 'goalkeeper', description: '-', birthday: Date.strptime('4/7/92', '%d/%m/%y'), nationality: 'Argentina', weight: '79', height: '1.85' },
    { first_name: 'Manuel', last_name: 'Guanini', position: 'defender', description: '-', birthday: Date.strptime('14/2/96', '%d/%m/%y'), nationality: 'Argentina', weight: '86', height: '1.91' },
    { first_name: 'Ezequiel', last_name: 'Bonifacio', position: 'midfielder', description: '-', birthday: Date.strptime('9/5/94', '%d/%m/%y'), nationality: 'Argentina', weight: '69', height: '1.69' },
    { first_name: 'Luciano', last_name: 'Perdomo', position: 'midfielder', description: '-', birthday: Date.strptime('10/9/96', '%d/%m/%y'), nationality: 'Argentina', weight: '70', height: '1.74' },
    { first_name: 'Matias', last_name: 'Garcia', position: 'midfielder', description: '-', birthday: Date.strptime('22/10/91', '%d/%m/%y'), nationality: 'Argentina', weight: '71', height: '1.74' },
    { first_name: 'Horacio', last_name: 'Tijanovich', position: 'forward', description: '-', birthday: Date.strptime('28/2/96', '%d/%m/%y'), nationality: 'Argentina', weight: '68', height: '1.73' },
    { first_name: 'Walter', last_name: 'Bou', position: 'forward', description: '-', birthday: Date.strptime('25/8/93', '%d/%m/%y'), nationality: 'Argentina', weight: '69', height: '1.74' }
  ])
  gimnasia = Team.create!(name: 'Gimnasia LP', director: gimnasia_director, players: gimnasia_players, description: 'El Lobo', short_name: 'GIM')




  ## PARTIDOS
  slo_ind = Match.create!(tournament: torneo_verano, title: 'San Lorenzo vs Independiente', local_team: san_lorenzo, visitor_team: independiente, datetime: DateTime.strptime('12/1/16 22:10', '%d/%m/%y %H:%M'))
  est_rac = Match.create!(tournament: torneo_verano, title: 'Estudiantes LP vs Racing', local_team: estudiantes, visitor_team: racing, datetime: DateTime.strptime('14/1/16 22:10', '%d/%m/%y %H:%M'))
  slo_hur = Match.create!(tournament: torneo_verano, title: 'San Lorenzo vs Huracan', local_team: san_lorenzo, visitor_team: huracan, datetime: DateTime.strptime('16/1/16 22:10', '%d/%m/%y %H:%M'))
  riv_ind = Match.create!(tournament: torneo_verano, title: 'River vs Independiente', local_team: river, visitor_team: independiente, datetime: DateTime.strptime('18/1/16 22:10', '%d/%m/%y %H:%M'))
  boc_rac = Match.create!(tournament: torneo_verano, title: 'Boca vs Racing', local_team: boca, visitor_team: racing, datetime: DateTime.strptime('20/1/16 22:10', '%d/%m/%y %H:%M'))
  boc_riv = Match.create!(tournament: torneo_verano, title: 'Boca vs River', local_team: boca, visitor_team: river, datetime: DateTime.strptime('23/1/16 22:10', '%d/%m/%y %H:%M'))
  riv_slo = Match.create!(tournament: torneo_verano, title: 'River vs San Lorenzo', local_team: river, visitor_team: san_lorenzo, datetime: DateTime.strptime('26/1/16 22:10', '%d/%m/%y %H:%M'))
  boc_est = Match.create!(tournament: torneo_verano, title: 'Boca vs Estudiantes', local_team: boca, visitor_team: estudiantes, datetime: DateTime.strptime('27/1/16 22:10', '%d/%m/%y %H:%M'))
  rac_ind = Match.create!(tournament: torneo_verano, title: 'Racing vs Independiente', local_team: racing, visitor_team: independiente, datetime: DateTime.strptime('29/1/16 22:10', '%d/%m/%y %H:%M'))
  est_gim = Match.create!(tournament: torneo_verano, title: 'Estudiantes LP vs Gimnasia LP', local_team: estudiantes, visitor_team: gimnasia, datetime: DateTime.strptime('31/1/16 22:10', '%d/%m/%y %H:%M'))



  ## MESAS
  Table.create!(title: 'San Lorenzo vs Independiente', matches: [slo_ind], start_time: slo_ind.datetime, end_time: slo_ind.datetime + 1.day, tournament: torneo_verano,
               number_of_players: 3, points_for_winners: PointsForWinners.default, description: '-', table_rules: TableRules.create,
               entry_coins_cost: 0)
               
  ## PLAYER STATS
  
  bonnin = Player.find_by(first_name: 'Yair', last_name: 'Bonnin', team: gimnasia)
  PlayerStats.create!(player: bonnin, match: slo_ind,
  shots: 0, shots_on_goal: 0, shots_to_the_post: 0, shots_outside: 0, 
  scored_goals: 0, goalkeeper_scored_goals:0, defender_scored_goals: 0, free_kick_goal:0,
  right_passes: 10, recoveries:0, assists: 0, undefeated_defense: 0, wrong_passes:0, 
  saves: 0, saved_penalties:0,missed_saves:0,undefeated_goal: 0,  
  red_cards: 0, yellow_cards: 0, offside: 0, faults: 0, missed_penalties: 0, winner_team: 0
  )
 
end