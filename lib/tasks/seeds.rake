namespace :seeds do
  task torneo_verano: :environment do
    Dir[File.join(Rails.root, 'db', 'seeds', 'torneo_verano.rb')].each { |filename| load filename }
  end

  task torneo_clausura: :environment do
    Dir[File.join(Rails.root, 'db', 'seeds', 'torneo_clausura.rb')].each { |filename| load filename }
  end

  task torneo_clausura_abm: :environment do
    Dir[File.join(Rails.root, 'db', 'seeds', 'torneo_clausura_alta_jugadores.rb')].each { |filename| load filename }
  end
end
