class Admin::TablesController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Mesa creada'
  UPDATE_SUCCESS_MESSAGE = 'Mesa actualizada'
  DESTROY_SUCCESS_MESSAGE = 'Mesa eliminada'
  CLOSE_SUCCESS_MESSAGE = 'Mesa cerrada y mails con resultados enviados'

  def index
    @tables = Table.all
  end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new table_params
    @table.save!
    add_table_rules
    redirect_with_success_message admin_tables_path, CREATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/tables/new', error
  end

  def edit
    @table = Table.find(params[:id])
  end

  def update
    @table = Table.find(params[:id])
    @table.update!(table_params)
    redirect_with_success_message admin_tables_path, UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/tables/edit', error
  end

  def show
    @table = Table.find(params[:id])
    render 'admin/tables/show'
  end

  def destroy
    @table = Table.find(params[:id])
    @table.destroy!
    redirect_with_success_message admin_tables_path, DESTROY_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordNotFound => error
    redirect_with_error_message :index, error
  end

  def to_be_closed
    @tables_to_be_closed = Table.where(opened: true).where('end_time < ?', Time.now)
  end

  def close
    @table = Table.find(params[:id]) 
    croupier.assign_scores(players_stats: create_player_stats)
    RankingSorter.new(@table.tournament).call
    ResultsMailer.for_table(@table)
    redirect_with_success_message to_be_closed_admin_tables_path, CLOSE_SUCCESS_MESSAGE
  rescue ArgumentError, ActiveRecord::RecordInvalid => error
    redirect_with_error_message to_be_closed_admin_tables_path, error
  rescue ActiveRecord::UnknownAttributeError => error
    message = "Valid stat attributes are: #{PlayerStats::FEATURES.join(', ')}"
    redirect_with_error_message to_be_closed_admin_tables_path, error, message
  end

  private

  def table_params
    permitted_params = params.require(:table).permit(:title, :entry_coins_cost, :number_of_players, :description, :tournament_id, match_ids: [])
    permitted_params[:matches] = Match.where(id: permitted_params.delete(:match_ids))
    permitted_params[:points_for_winners] = PointsForWinners.default
    permitted_params[:start_time] = permitted_params[:matches].map(&:datetime).min
    permitted_params[:end_time] =  permitted_params[:matches].map(&:datetime).min + 2.hours
    permitted_params
  end

  def create_player_stats
    PlayerStatsCSVImporter.new(params[:player_stats][:file], @table).import
  end

  def croupier
    Croupier.for(@table)
  end

  def add_table_rules
    TableRules.create!(table: @table)
  end
end
