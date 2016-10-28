class Api::V1::GroupsController < Api::BaseController
  GROUP_NOT_FOUND = 'Given group was not found'
  USER_DOES_NOT_BELONG_TO_GIVEN_GROUP = 'You can not access to that group information'

  def show
    return render_user_does_not_belong_to_group unless group.has_user? current_user
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
  end

  def create
    @group = Group.new(group_params.merge(users: [current_user]))
    return render :show if group.save
    render_json_errors group.errors
  end

  def update
    update_handling_errors { group.update group_params }
  end

  def exit
    update_handling_errors { group.remove current_user }
  end

  def add_member
    new_member = User.find(params[:user_id])
    update_handling_errors {
      group.add new_member
      group.save
    }
  rescue ActiveRecord::RecordNotFound
    render_not_found_error GROUP_NOT_FOUND
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

  def group_params
    params.require(:group).permit(:name)
  end

  def group
    @group ||= Group.find(params[:id])
  end
end
