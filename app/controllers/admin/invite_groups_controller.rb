class Admin::InviteGroupsController < Admin::BaseController
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]

  def show
  end

  def edit
  end

  def update
    if @invite_group.update(invite_group_params)
      redirect_to admin_invite_group_path(@invite_group), notice: "Group updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invite_group.destroy
    redirect_to admin_guests_path(view: "groups"), notice: "Group and its guests deleted."
  end

  private

  def set_group
    @invite_group = InviteGroup.includes(:guests).find(params[:id])
  end

  def invite_group_params
    params.require(:invite_group).permit(:name, :email, :weecasa_included, :weecasa_response)
  end
end
