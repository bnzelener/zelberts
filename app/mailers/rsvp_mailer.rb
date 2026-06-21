class RsvpMailer < ApplicationMailer
  # Sent right after a party submits (or updates) their RSVP, to the address
  # they gave when opting into wedding updates. Reuses the shared mailer layout;
  # future reminder emails are additional methods here that do the same.
  def confirmation(invite_group)
    @invite_group = invite_group
    # Primary guests only — plus-ones are summarized under their host, matching
    # the on-screen RSVP summary page.
    @guests = invite_group.guests.select { |g| g.plus_one_host_id.nil? }
    @events = Event.all.to_a

    mail(
      to: invite_group.email,
      subject: "We got your RSVP — Ali & Brennan's wedding"
    )
  end

  # Sent to the couple every time any party submits or updates an RSVP, so they
  # get a heads-up regardless of whether the guests opted into updates. Goes to
  # the same Gmail that replies are routed to; override via ENV without a code
  # change.
  def host_notification(invite_group)
    @invite_group = invite_group
    # Primary guests only — plus-ones are summarized under their host, matching
    # the on-screen RSVP summary page.
    @guests = invite_group.guests.select { |g| g.plus_one_host_id.nil? }
    @events = Event.all.to_a

    mail(
      to: ENV.fetch("HOST_NOTIFY_TO", "thezelberts@gmail.com"),
      subject: "RSVP from #{invite_group.name}"
    )
  end
end
