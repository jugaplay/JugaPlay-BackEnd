class Admin::TeamsController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Equipo creado'
  UPDATE_SUCCESS_MESSAGE = 'Equipo actualizado'
  DESTROY_SUCCESS_MESSAGE = 'Equipo eliminado'
  IMPORT_SUCCESS_MESSAGE = 'Jugadores importados'

  def index
    @teams = Team.all
  end

  def new
    @director = Director.new
    @team = Team.new
  end

  def create
    @director = Director.new director_params
    @team = Team.new team_params.merge(director: @director)
    @team.save!
    redirect_with_success_message admin_teams_path, CREATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/teams/new', error
  end

  def edit
    @team = Team.find(params[:id])
    @director = @team.director
  end

  def update
    @team = Team.find(params[:id])
    @team.director.update!(director_params)
    @team.update!(team_params)
    redirect_with_success_message admin_teams_path, UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/teams/edit', error
  end

  def show
    @team = Team.find(params[:id])
    render 'admin/teams/show'
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy!
    redirect_with_success_message admin_teams_path, DESTROY_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordNotFound => error
    redirect_with_error_message :index, error
  end

  def import_players
    @team = Team.find(params[:id])
    PlayersCSVImporter.new(@team, params[:players][:file]).import
    redirect_with_success_message admin_team_path(@team.id), IMPORT_SUCCESS_MESSAGE
  rescue ArgumentError, ActiveRecord::RecordInvalid => error
    redirect_with_error_message admin_team_path(@team.id), error
  rescue ActiveRecord::UnknownAttributeError => error
    message = 'Please look at the example below, some keyword given in the CSV is invalid'
    redirect_with_error_message admin_team_path(@team.id), error, message
  end

  private

  def team_params
    params.require(:team).permit(:name, :short_name, :description)
  end

  def director_params
    params.require(:team).require(:director).permit(:first_name, :last_name, :description)
  end
end
