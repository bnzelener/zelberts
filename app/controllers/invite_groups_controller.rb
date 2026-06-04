class InviteGroupsController < ApplicationController
  before_action :set_group, only: [ :form, :submit, :confirmation ]

  def form
    @events = Event.all
    build_missing_event_responses
  end

  def submit
    if @invite_group.update(invite_group_params)
      redirect_to confirmation_invite_group_path(@invite_group)
    else
      @events = Event.all
      build_missing_event_responses
      flash.now[:alert] = "Please review the highlighted fields below."
      render :form, status: :unprocessable_entity
    end
  end

  def confirmation
    @events = Event.all
  end

  private

  def set_group
    @invite_group = InviteGroup.includes(guests: :event_responses).find(params[:id])
  end

  # Ensure every guest has an in-memory EventResponse for every event so the
  # form renders a row per event. Persisted responses keep their id (→ UPDATE);
  # newly built ones have no id (→ INSERT on submit).
  def build_missing_event_responses
    events = Event.all.to_a
    @invite_group.guests.each do |guest|
      existing_event_ids = guest.event_responses.map(&:event_id)
      events.each do |event|
        next if existing_event_ids.include?(event.id)
        guest.event_responses.build(event: event, attending: false)
      end
    end
  end

  def invite_group_params
    params.require(:invite_group).permit(
      guests_attributes: [
        :id, :attending, :dietary_notes, :plus_one, :plus_one_name,
        { event_responses_attributes: [ :id, :event_id, :attending ] }
      ]
    )
  end
end
