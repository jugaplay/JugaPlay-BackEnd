class Api::V1::TablesController < Api::BaseController
  PRIVATE_TABLE_NUMBER_OF_PLAYERS = 3
  TABLE_NOT_FOUND = 'No se encontró la mesa solicitada'
  MATCH_NOT_FOUND = 'No se encontró el partido solicitado'
  GROUP_MUST_BE_GIVEN = 'No se ha indicado ningún grupo para la mesa'
  PRIVATE_TABLE_NOT_ALLOWED = 'No tienes permiso para acceder a la mesa privada solicitada'
  ENTRY_COINS_COST_MUST_BE_GREATER_THAN_OR_EQ_TO_ZERO = 'El monto de monedas para apostar debe ser mayor o igual a cero'

  def index
    public_tables = Table.opened.publics
    private_tables = Table.opened.privates_for(current_user)
    @tables = public_tables + private_tables
  end

  def show
    return render_json_error PRIVATE_TABLE_NOT_ALLOWED unless table.can_play?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_not_found_error TABLE_NOT_FOUND
  end

  def create
    return render_json_error GROUP_MUST_BE_GIVEN unless table_params[:group_id].present?
    return render_json_error ENTRY_COINS_COST_MUST_BE_GREATER_THAN_OR_EQ_TO_ZERO unless table_params[:entry_coins_cost].to_i >= 0
    @table = Table.new private_table_params
    return render_json_errors table.errors unless table.save
    create_notifications_for_table_group
    render :show
  rescue ActiveRecord::RecordNotFound
    render_not_found_error MATCH_NOT_FOUND
  end

  private

  def create_notifications_for_table_group
    table.group.users.each do |user|
      Notification.challenge!(title: table.group.name, text: table.title, user: user)
    end
  end

  def table_params
    params.require(:table).permit(:title, :description, :match_id, :group_id, :entry_coins_cost)
  end

  def private_table_params
    private_table_params = table_params
    match = Match.find(private_table_params.delete(:match_id))
    private_table_params[:matches] = [match]
    private_table_params[:status] = :opened
    private_table_params[:tournament_id] = match.tournament_id
    private_table_params[:number_of_players] = PRIVATE_TABLE_NUMBER_OF_PLAYERS
    private_table_params[:table_rules] = TableRules.new
    private_table_params[:coins_for_winners] = []
    private_table_params[:points_for_winners] = []
    private_table_params[:start_time] = match.datetime
    private_table_params[:end_time] = match.datetime + 2.hours
    private_table_params
  end

  def table
    @table ||= Table.includes(matches: [{ local_team: :players }, { visitor_team: :players }]).find(params[:id])
  end
end
