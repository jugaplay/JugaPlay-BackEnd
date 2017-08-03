class Admin::TablesController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Mesa creada'
  UPDATE_SUCCESS_MESSAGE = 'Mesa actualizada'
  DESTROY_SUCCESS_MESSAGE = 'Mesa eliminada'
  CLOSING_TABLE_ENQUEUED_MESSAGE = 'Se está cerrando la mesa en background'
  CLOSING_TABLES_ENQUEUED_MESSAGE = 'Se están cerrando la mesas en background'

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
    @tables_to_be_closed = Table.not_closed.closest_first
  end

  def close
    errors = ClosingTablesWorker.for(table).call
    return redirect_with_success_message to_be_closed_admin_tables_path, CLOSING_TABLE_ENQUEUED_MESSAGE if errors.empty?
    redirect_with_error_messages to_be_closed_admin_tables_path, errors.map { |e| e[:error_message] }
  end

  def close_all
    errors = ClosingTablesWorker.for_all_tables_to_be_closed.call
    message = "Se están cerrando las mesas en background. Las siguientes mesas no se pudieron cerrar por distintos errores: \n"
    message += errors.map { |error| "#{error[:table].title}: #{error[:error_message]}" }.join('\n')
    redirect_with_success_message admin_tables_path, message
  end

  private

  def table_params
    permitted_params = params.require(:table).permit(:title, :entry_cost_value, :entry_cost_type, :number_of_players, :description, :tournament_id, match_ids: [])
    permitted_params[:matches] = Match.where(id: permitted_params.delete(:match_ids))
    permitted_params[:status] = :opened
    permitted_params[:prizes] = []
    permitted_params[:points_for_winners] = PointsForWinners.default
    permitted_params[:start_time] = permitted_params[:matches].map(&:datetime).min
    permitted_params[:end_time] =  permitted_params[:matches].map(&:datetime).min + 2.hours
    permitted_params
  end

  def table
    @table ||= Table.find(table_id)
  end

  def table_id
    @table_id ||= params[:id]
  end
end
