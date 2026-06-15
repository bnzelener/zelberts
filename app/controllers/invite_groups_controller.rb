class InviteGroupsController < ApplicationController
  before_action :set_group, only: [ :show, :form, :submit ]

  # The RSVP "show" page: a summary of the party's responses. Doubles as the
  # post-submit confirmation and the landing page when someone looks up an
  # existing RSVP.
  def show
    @events = Event.all
  end

  def form
    @events = Event.all
    build_missing_event_responses
  end

  def submit
    @invite_group.assign_attributes(invite_group_params)
    if @invite_group.save(context: :rsvp)
      redirect_to invite_group_path(@invite_group), notice: "Thank you! Your RSVP has been saved."
    else
      @events = Event.all
      build_missing_event_responses
      flash.now[:alert] = "Please review the highlighted fields below."
      render :form, status: :unprocessable_entity
    end
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
      :weecasa_response,
      guests_attributes: [
        :id, :attending, :dietary_notes, :plus_one, :plus_one_name,
        { event_responses_attributes: [ :id, :event_id, :attending ] }
      ]
    )
  end
end
