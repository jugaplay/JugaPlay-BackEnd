class Admin::PlayerStatsController < Admin::BaseController
  PLAYERS_STATS_IMPORTED_SUCCESSFULLY = 'Player stats were imported successfully'

  def import
    errors = csv_importer.import
    return redirect_with_error_messages(import_form_admin_player_stats_path, errors) unless errors.empty?
    redirect_with_success_message import_form_admin_player_stats_path, PLAYERS_STATS_IMPORTED_SUCCESSFULLY
  rescue ArgumentError, ActiveRecord::RecordInvalid => error
    redirect_with_error_message import_form_admin_player_stats_path, error
  rescue ActiveRecord::UnknownAttributeError => error
    message = "Valid stat attributes are: #{PlayerStats::FEATURES.join(', ')}"
    redirect_with_error_message import_form_admin_player_stats_path, error, message
  end

  private

  def player_stats_file
    params.require(:player_stats).permit(:file)
  end

  def csv_importer
    PlayerStatsCSVImporter.new(player_stats_file[:file])
  end
end
