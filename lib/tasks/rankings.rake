namespace :rankings do
  task update_with_plays_points: :environment do
    Tournament.find_each do |tournament|

      puts "Analyzing table rankings with plays points for tournament #{tournament.id}"
      table_rankings = ActiveRecord::Base.connection.execute("
        SELECT table_rankings.id AS table_ranking_id, plays.points AS play_points
        FROM plays
          INNER JOIN table_rankings ON table_rankings.play_id = plays.id
          INNER JOIN tables ON plays.table_id = tables.id
        WHERE tables.tournament_id='#{tournament.id}' AND group_id IS NULL
      ")
      puts "Preparing #{table_rankings.count} table rankings to update"
      queries = table_rankings.map { |data| "UPDATE table_rankings SET points = #{data['play_points']} WHERE id = #{data['table_ranking_id']}" }
      puts "Updating #{queries.count} table rankings"
      ActiveRecord::Base.connection.execute(queries.join(';'))


      puts "Analyzing tournament rankings for tournament #{tournament.id}"
      users_play_points = ActiveRecord::Base.connection.execute("
        SELECT user_id, users.created_at AS anniversary, SUM(GREATEST(plays.points, 0)) AS points
        FROM plays INNER JOIN tables ON plays.table_id = tables.id INNER JOIN users ON plays.user_id = users.id
        WHERE tables.tournament_id='#{tournament.id}' AND group_id IS NULL
        GROUP BY user_id, anniversary
        ORDER BY points DESC, anniversary ASC
      ")
      puts "Preparing #{users_play_points.count} tournament rankings to update"
      queries = users_play_points.map.with_index do |data, index|
        "INSERT INTO rankings (tournament_id, user_id, points, position) VALUES(#{tournament.id}, #{data['user_id']}, #{data['points']}, #{index + 1})"
      end
      puts "Updating #{queries.count} tournament rankings"
      ActiveRecord::Base.connection.execute("DELETE FROM rankings WHERE tournament_id='#{tournament.id}'")
      ActiveRecord::Base.connection.execute(queries.join(';'))

      puts '-----------------------------------------------------------'
    end
  end

  task :points_explain_all_tournaments, [:tournament_id, :verbose] => [:environment] do |t, args|
    tournament_ids = Tournament.all.pluck('id')
    puts "Summarying #{tournament_ids.count} tournaments"
    tournament_ids.each do |tournament_id|
      Rake::Task['rankings:points_explain_single_tournament'].invoke(tournament_id, args[:verbose])
      Rake::Task['rankings:points_explain_single_tournament'].reenable
    end
  end

  task :points_explain_single_tournament, [:tournament_id, :verbose] => [:environment] do |t, args|
    verbose = args[:verbose].eql? 'true'
    tournament = Tournament.find(args[:tournament_id])

    users_play_points = ActiveRecord::Base.connection.execute("
      SELECT user_id, users.nickname AS nick, SUM(GREATEST(plays.points, 0)) AS plays_points, SUM(table_rankings.points) AS table_ranking_points
        FROM plays
          INNER JOIN tables ON plays.table_id = tables.id INNER JOIN users ON plays.user_id = users.id
          INNER JOIN table_rankings ON plays.id = table_rankings.play_id
        WHERE tables.tournament_id='#{tournament.id}' AND group_id IS NULL
        GROUP BY user_id, nick
    ")

    puts "TOURNAMENT ##{tournament.id} #{tournament.name.upcase} (#{users_play_points.count} users playing)"
    results = { ok: [], warnings: [], missing_rankings: [] }

    users_play_points.each do |data|
      user_id = data['user_id']
      play_points = data['plays_points'].to_f
      table_ranking_points = data['table_ranking_points'].to_f
      ranking = Ranking.find_by(tournament: tournament, user_id: user_id)

      message = nil
      if ranking.nil?
        message = "[ERROR] Missing ranking for user #{data['nick']} (#{user_id})"
        results[:missing_rankings] << message 
      else
        ranking_points = ranking.points
        warning = ranking_points != play_points || ranking_points != table_ranking_points
        status = warning ? 'WARN' : 'OK'
        message = "[#{status}] #{data['nick']} (#{user_id}): #{table_ranking_points} (table ranking points) - #{play_points} (plays points) - #{ranking_points} (ranking points)"
        warning ? (results[:warnings] << message) : (results[:ok] << message)
      end
      
      puts message if verbose
    end

    puts "OK: #{results[:ok].count}"
    puts "Warnings: #{results[:warnings].count}"
    puts "Missing rankings: #{results[:missing_rankings].count}"
    puts '-----------------------------------------------------------'
  end

  task :points_explain_single_tournament_for_user, [:tournament_id, :user_id] => [:environment] do |t, args|
    user = User.find(args[:user_id])
    tournament = Tournament.find(args[:tournament_id])
    plays = Play.joins(:table).where(user: user).where('tournament_id = ?', tournament.id)

    puts "Summary for user #{user.nickname} (#{user.id}) in tournament #{tournament.name} (#{tournament.id})\n\n"

    keys = [:index, :play_id, :created_at, :table, :table_id, :end_at, :status, :play_points, :table_ranking_points, :table_ranking_position]
    values = plays.map.with_index do |play, i|
      table = play.table
      table_ranking = play.table_ranking
      table_ranking_points = table_ranking.present? ? table_ranking.points : 'missing'
      table_ranking_position = table_ranking.present? ? table_ranking.position : 'missing'
      {
        index: i+1,
        play_id: play.id,
        created_at: play.created_at.strftime('%d/%m/%Y - %H:%M'),
        table: table.title,
        table_id: table.id,
        end_at: table.end_time.strftime('%d/%m/%Y - %H:%M'),
        status: table.status,
        play_points: play.points,
        table_ranking_points: table_ranking_points,
        table_ranking_position: table_ranking_position,
      }
    end

    TablePrinter.new(keys, values).call
  end
end
