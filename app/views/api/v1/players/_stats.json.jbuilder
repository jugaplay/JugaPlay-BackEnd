json.partial! partial: 'api/v1/players/player', locals: { player: player }

json.stats do |stat|
  if player_stats.nil?
    stat.set!(:error, 'Not imported yet')
  else
    PlayerStats::FEATURES.each do |feature|
      stat.set!(feature, player_stats.send(feature))
    end
  end
end
