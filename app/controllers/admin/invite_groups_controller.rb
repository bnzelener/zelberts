class Admin::InviteGroupsController < Admin::BaseController
  before_action :set_group, only: [ :show, :update ]

  def show
  end

  def update
    if @invite_group.update(invite_group_params)
      redirect_to admin_invite_group_path(@invite_group), notice: "Group updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @invite_group = InviteGroup.includes(:guests).find(params[:id])
  end

  def invite_group_params
    params.require(:invite_group).permit(:weecasa_included)
  end
end
