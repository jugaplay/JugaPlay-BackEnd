class Api::V1::GroupsController < Api::BaseController
  GROUP_NOT_FOUND = 'Given group was not found'
  INVALID_INVITATION_TOKEN = 'Invalid invitation token'
  USER_DOES_NOT_BELONG_TO_GIVEN_GROUP = 'You can not access to that group information'

  def index
    @groups = current_user.groups
  end

  def show
    return render_user_does_not_belong_to_group unless group.has_user? current_user
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
  end

  def create
    @group = Group.new create_group_params
    return render_json_errors group.errors unless group.save
    GroupInvitationToken.create_for_group! group
    render :show
  end

  def update
    update_handling_errors { group.update update_group_params }
  end

  def exit
    update_handling_errors { group.remove current_user }
  end

  def add_member
    new_member = User.find(params[:user_id])
    update_handling_errors do
      group.add new_member
      group.save
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
  end

  def join
    group_invitation_token = GroupInvitationToken.find_by_token(params[:token])
    return render_json_error INVALID_INVITATION_TOKEN if group_invitation_token.nil? || group_invitation_token.expired?
    @group = group_invitation_token.group
    group.add current_user
    group.save
    render :show
  end

  private

  def update_handling_errors
    return render_user_does_not_belong_to_group unless group.has_user? current_user
    return render :show if yield
    render_json_errors group.errors
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
  end

  def render_user_does_not_belong_to_group
    render_json_error USER_DOES_NOT_BELONG_TO_GIVEN_GROUP
  end

  def update_group_params
    params.require(:group).permit(:name)
  end

  def create_group_params
    group_params = params.require(:group).permit(:name, user_ids: [])
    group_params[:user_ids] = [current_user.id] + (group_params[:user_ids] || [])
    group_params
  end

  def group
    @group ||= Group.find(params[:id])
  end
end
