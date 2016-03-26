class Admin::PlayersController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Jugador creado'
  UPDATE_SUCCESS_MESSAGE = 'Jugador actualizado'
  DESTROY_SUCCESS_MESSAGE = 'Jugador eliminado'

  def index
    @players = Player.all.joins('LEFT JOIN teams ON team_id=teams.id').order('teams.name', :first_name, :last_name)
  end

  def new
    @player = Player.new
    load_player_birthday
  end

  def create
    @player = Player.new player_params
    load_player_birthday
    @player.save!
    redirect_with_success_message admin_players_path, CREATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/players/new', error
  end

  def edit
    @player = Player.find(params[:id])
    load_player_birthday
  end

  def update
    @player = Player.find(params[:id])
    load_player_birthday
    @player.update!(player_params)
    redirect_with_success_message admin_players_path, UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/players/edit', error
  end

  def show
    @player = Player.find(params[:id])
    render 'admin/players/show'
  end

  def destroy
    @player = Player.find(params[:id])
    @player.destroy!
    redirect_with_success_message admin_players_path, DESTROY_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordNotFound => error
    redirect_with_error_message :index, error
  end

  private

  def player_params
    player_params = params.require(:player).permit(:first_name, :last_name, :team_id, :position, :nationality, :description, :birthday, :weight, :height)
    player_params[:birthday] = Date.strptime(player_params.delete(:birthday), '%Y-%m-%d')
    player_params
  end

  def load_player_birthday
    @birthday = (@player.birthday || DateTime.now).to_datetime
  end
end
