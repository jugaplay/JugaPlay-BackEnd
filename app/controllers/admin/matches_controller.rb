class Admin::MatchesController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Partido creado'
  UPDATE_SUCCESS_MESSAGE = 'Partido actualizado'
  DESTROY_SUCCESS_MESSAGE = 'Partido eliminado'

  def index
    @matches = Match.all.order(tournament_id: :desc, datetime: :desc)
  end

  def new
    @match = Match.new
    load_match_datetime
  end

  def create
    @match = Match.new match_params
    load_match_datetime
    @match.save!
    redirect_with_success_message admin_matches_path, CREATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/matches/new', error
  end

  def edit
    @match = Match.find(params[:id])
    load_match_datetime
  end

  def update
    @match = Match.find(params[:id])
    load_match_datetime
    @match.update!(match_params)
    redirect_with_success_message admin_matches_path, UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/matches/edit', error
  end

  def show
    @match = Match.find(params[:id])
    render 'admin/matches/show'
  end

  def destroy
    @match = Match.find(params[:id])
    @match.destroy!
    redirect_with_success_message admin_matches_path, DESTROY_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordNotFound => error
    redirect_with_error_message :index, error
  end

  private

  def match_params
    match_params = params.require(:match).permit(:title, :local_team_id, :visitor_team_id, :tournament_id, :datetime)
    match_params[:datetime] = DateTime.strptime(match_params.delete(:datetime), '%Y-%m-%d %H:%M')
    match_params
  end

  def load_match_datetime
    @now = (@match.datetime || DateTime.now).to_datetime
  end
end
