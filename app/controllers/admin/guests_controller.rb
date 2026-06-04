class Admin::GuestsController < Admin::BaseController
  before_action :set_guest, only: [ :edit, :update ]

  def index
    @view = params[:view] == "groups" ? "groups" : "guests"
    @query = params[:q].to_s.strip

    @guests = Guest.includes(:invite_group).order(created_at: :desc)
    @guests = @guests.merge(Guest.search(@query)) if @query.present?

    if @view == "groups"
      @invite_groups = InviteGroup.includes(:guests).order(:name)
      @ungrouped_guests = Guest.where(invite_group_id: nil).order(:last_name)
      if @query.present?
        matching_group_ids = Guest.search(@query).where.not(invite_group_id: nil).distinct.pluck(:invite_group_id)
        term = "%#{@query.downcase}%"
        @invite_groups = @invite_groups.where(
          "lower(invite_groups.name) LIKE :t OR lower(invite_groups.email) LIKE :t OR invite_groups.id IN (:ids)",
          t: term, ids: matching_group_ids.presence || [ -1 ]
        )
        @ungrouped_guests = @ungrouped_guests.merge(Guest.search(@query))
      end
    end

    @attending_count = Guest.attending.count
    @not_attending_count = Guest.not_attending.count
    @pending_count = Guest.pending.count
  end

  def edit
  end

  def update
    if @guest.update(guest_params)
      redirect_to admin_guests_path, notice: "Guest updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_guest
    @guest = Guest.find(params[:id])
  end

  def guest_params
    params.require(:guest).permit(
      :first_name, :last_name, :phone, :dietary_notes, :plus_one_allowed, :invite_group_id
    )
  end
end
