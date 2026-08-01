class Admin::GuestsController < Admin::BaseController
  before_action :set_guest, only: [ :edit, :update ]

  def index
    @view = params[:view] == "groups" ? "groups" : "guests"
    @query = params[:q].to_s.strip

    # Lead with guests who have responded (most recent first); pending fall to
    # the bottom.
    @guests = Guest.includes(:invite_group, :plus_one_guest, :plus_one_host)
                   .order(Arel.sql("guests.responded_at DESC NULLS LAST"))
                   .order(created_at: :desc)
    @guests = @guests.merge(Guest.search(@query)) if @query.present?

    if @view == "groups"
      @invite_groups = InviteGroup.includes(:guests)
      @ungrouped_guests = Guest.where(invite_group_id: nil)
                               .order(Arel.sql("responded_at DESC NULLS LAST"))
                               .order(:last_name)
      if @query.present?
        matching_group_ids = Guest.search(@query).where.not(invite_group_id: nil).distinct.pluck(:invite_group_id)
        term = "%#{@query.downcase}%"
        @invite_groups = @invite_groups.where(
          "lower(invite_groups.name) LIKE :t OR lower(invite_groups.email) LIKE :t OR invite_groups.id IN (:ids)",
          t: term, ids: matching_group_ids.presence || [ -1 ]
        )
        @ungrouped_guests = @ungrouped_guests.merge(Guest.search(@query))
      end

      # Lead with groups that have at least one response, then alphabetically.
      @invite_groups = @invite_groups.to_a.sort_by do |group|
        [ group.guests.any? { |g| g.responded_at.present? } ? 0 : 1, group.name.to_s.downcase ]
      end
    end

    @attending_count = Guest.attending.count
    @not_attending_count = Guest.not_attending.count
    @pending_count = Guest.pending.count
  end

  def edit
    build_missing_event_responses
  end

  def update
    if @guest.update(guest_params)
      redirect_to admin_guests_path, notice: "Guest updated."
    else
      build_missing_event_responses
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_guest
    @guest = Guest.find(params[:id])
  end

  # Ensure the guest has an in-memory EventResponse for every event so the edit
  # form renders a checkbox per event. Persisted responses keep their id
  # (→ UPDATE); newly built ones have no id (→ INSERT on save).
  def build_missing_event_responses
    existing_event_ids = @guest.event_responses.map(&:event_id)
    Event.all.each do |event|
      next if existing_event_ids.include?(event.id)
      @guest.event_responses.build(event: event, attending: false)
    end
  end

  def guest_params
    params.require(:guest).permit(
      :first_name, :last_name, :phone, :dietary_notes, :plus_one_allowed, :invite_group_id,
      :attending, :plus_one, :plus_one_first_name, :plus_one_last_name,
      event_responses_attributes: [ :id, :event_id, :attending ]
    )
  end
end
