class Api::V1::GroupsController < Api::BaseController
  GROUP_NOT_FOUND = 'Given group was not found'
  USER_DOES_NOT_BELONG_TO_GIVEN_GROUP = 'You can not access to that group information'

  def create
    @group = Group.new(group_params)
    return render :show if @group.save
    render_json_errors @group.errors
  end

  def show
    return render_user_does_not_belong_to_group unless group.has_user? current_user
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
  end

  def update
    return render_user_does_not_belong_to_group unless group.has_user? current_user
    return render :show if @group.update(group_params)
    render_json_errors @group.errors
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
  end

  private

  def render_user_does_not_belong_to_group
    render_json_error USER_DOES_NOT_BELONG_TO_GIVEN_GROUP
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def group_params
    group_params = params.require(:group).permit(:name, user_ids: [])
    group_params[:users] = User.where(id: group_params.delete(:user_ids))
    group_params
  end
end
