class Admin::TablesController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Mesa creada'
  UPDATE_SUCCESS_MESSAGE = 'Mesa actualizada'
  DESTROY_SUCCESS_MESSAGE = 'Mesa eliminada'
  CLOSE_SUCCESS_MESSAGE = 'Mesa cerrada y mails con resultados enviados'

  before_action :table, only: [:edit, :show]

  def show
    render 'admin/tables/show'
  end

  def index
    @tables = Table.all
  end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new table_params.merge(table_rules: TableRules.new)
    table.save!
    redirect_with_success_message admin_tables_path, CREATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/tables/new', error
  end

  def update
    table.update!(table_params)
    redirect_with_success_message admin_tables_path, UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/tables/edit', error
  end

  def destroy
    table.destroy!
    redirect_with_success_message admin_tables_path, DESTROY_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordNotFound => error
    redirect_with_error_message :index, error
  end

  def to_be_closed
    @tables_to_be_closed = Table.opened.where('end_time < ?', Time.now)
  end

  def close
    TableCloser.new(table).call
    ResultsMailer.for_table(table)
    redirect_with_success_message to_be_closed_admin_tables_path, CLOSE_SUCCESS_MESSAGE
  rescue MissingPlayerStats, ArgumentError, ActiveRecord::RecordInvalid => error
    redirect_with_error_message to_be_closed_admin_tables_path, error
  end

  private

  def table_params
    permitted_params = params.require(:table).permit(:title, :entry_coins_cost, :number_of_players, :description, :tournament_id, match_ids: [])
    permitted_params[:matches] = Match.where(id: permitted_params.delete(:match_ids))
    permitted_params[:coins_for_winners] = []
    permitted_params[:points_for_winners] = PointsForWinners.default
    permitted_params[:start_time] = permitted_params[:matches].map(&:datetime).min
    permitted_params[:end_time] =  permitted_params[:matches].map(&:datetime).min + 2.hours
    permitted_params
  end

  def table
    @table ||= Table.find(params[:id])
  end
end
