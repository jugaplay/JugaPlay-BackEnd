class Admin::ExplanationsController < Admin::BaseController
  CREATE_SUCCESS_MESSAGE = 'Explicación creada'
  UPDATE_SUCCESS_MESSAGE = 'Explicación actualizada'
  DESTROY_SUCCESS_MESSAGE = 'Explicación eliminada'
  
  
  def index
  	@explanations = Explanation.where(active: true).order(name: :asc)
  end

  def new
    @explanation = Explanation.new
  end

  def create
    @explanation = Explanation.new explanation_params
    @explanation.save!
    redirect_with_success_message admin_explanations_path, CREATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/explanations/new', error
  end

  def edit
    @explanation = Explanation.find(params[:id])
  end

  def update
    @explanation = Explanation.find(params[:id])
    @explanation.update!(explanation_params)
    redirect_with_success_message admin_explanations_path, UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'admin/explanations/edit', error
  end

  def show
    @explanation = Explanation.find(params[:id])
    render 'admin/explanations/show'
  end


  private

  def explanation_params
    explanation_params = params.require(:explanation).permit(:name, :detail)
    explanation_params
  end
  
  
  
end
