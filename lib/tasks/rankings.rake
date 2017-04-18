namespace :rankings do
  task update_with_plays_points: :environment do
    Tournament.find_each do |tournament|
      puts "Updating ranking for tournament #{tournament.id}"

      users_play_points = ActiveRecord::Base.connection.execute("
        SELECT user_id, users.created_at AS anniversary, SUM(GREATEST(plays.points, 0)) AS points
          FROM plays INNER JOIN tables ON plays.table_id = tables.id INNER JOIN users ON plays.user_id = users.id
          WHERE tables.tournament_id='#{tournament.id}'
          GROUP BY user_id, anniversary
          ORDER BY points DESC, anniversary ASC
      ")

      puts "Preparing #{users_play_points.count} rankings to update"

      queries = users_play_points.map.with_index do |data, index|
        "INSERT INTO rankings (tournament_id, user_id, points, position) VALUES(#{tournament.id}, #{data['user_id']}, #{data['points']}, #{index + 1})"
      end

      puts "Updating #{queries.count} rankings"
      ActiveRecord::Base.connection.execute("DELETE FROM rankings WHERE tournament_id='#{tournament.id}'")
      ActiveRecord::Base.connection.execute(queries.join(';'))

      puts '-----------------------------------------------------------'
    end
  end
end
