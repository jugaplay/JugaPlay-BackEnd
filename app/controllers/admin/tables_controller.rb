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
    can_be_closed_tables
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
    @tables_to_be_closed = Table.not_closed
  end

  def close
    enqueue_closing_table_job(table) { |redirect_error| return redirect_error }
    redirect_with_success_message to_be_closed_admin_tables_path, CLOSING_TABLE_ENQUEUED_MESSAGE
  end

  def close_all
    can_be_closed_tables.each do |table|
      enqueue_closing_table_job(table) { |redirect_error| return redirect_error }
    end
    message = "#{CLOSING_TABLES_ENQUEUED_MESSAGE}: #{can_be_closed_tables.map(&:title).join(', ')}"
    redirect_with_success_message admin_tables_path, message
  end

  private

  def enqueue_closing_table_job(table, &if_fail_block)
    table_closer_validator.validate_to_start_closing(table)
    table.start_closing!
    TableClosingJob.perform_later(table.id)
  rescue MissingPlayerStats, TableIsClosed => error
    redirect = redirect_with_error_message to_be_closed_admin_tables_path, error
    if_fail_block.call(redirect)
  end

  def table_params
    permitted_params = params.require(:table).permit(:title, :entry_coins_cost, :number_of_players, :description, :tournament_id, match_ids: [])
    permitted_params[:matches] = Match.where(id: permitted_params.delete(:match_ids))
    permitted_params[:status] = :opened
    permitted_params[:coins_for_winners] = []
    permitted_params[:points_for_winners] = PointsForWinners.default
    permitted_params[:start_time] = permitted_params[:matches].map(&:datetime).min
    permitted_params[:end_time] =  permitted_params[:matches].map(&:datetime).min + 2.hours
    permitted_params
  end

  def table_closer_validator
    @table_closer_validator ||= TableCloserValidator.new
  end

  def can_be_closed_tables
    @can_be_closed_tables ||= Table.can_be_closed
  end

  def table
    @table ||= Table.find(table_id)
  end

  def table_id
    @table_id ||= params[:id]
  end
end
