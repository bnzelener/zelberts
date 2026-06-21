require "test_helper"

class RsvpMailerTest < ActionMailer::TestCase
  setup do
    @event = Event.create!(name: "Welcome Dinner", date: Date.new(2026, 9, 11), sort_order: 1)
    @group = InviteGroup.create!(name: "The Smiths", email: "smiths@example.com", email_opt_in: true)
    @guest = @group.guests.create!(first_name: "Dana", last_name: "Smith", attending: true)
    @guest.event_responses.create!(event: @event, attending: true)
  end

  test "confirmation addresses the party's email with a clear subject" do
    mail = RsvpMailer.confirmation(@group)

    assert_equal [ "smiths@example.com" ], mail.to
    assert_match "RSVP", mail.subject
  end

  test "confirmation body summarizes the guest and their events" do
    mail = RsvpMailer.confirmation(@group)

    [ mail.html_part, mail.text_part ].each do |part|
      assert_match "Dana Smith", part.body.to_s
      assert_match "Welcome Dinner", part.body.to_s
    end
  end

  test "host notification goes to the couple regardless of opt-in" do
    mail = RsvpMailer.host_notification(@group)

    assert_equal [ "thezelberts@gmail.com" ], mail.to
    assert_match "The Smiths", mail.subject
  end

  test "host notification body summarizes the guest and their events" do
    mail = RsvpMailer.host_notification(@group)

    [ mail.html_part, mail.text_part ].each do |part|
      assert_match "Dana Smith", part.body.to_s
      assert_match "Welcome Dinner", part.body.to_s
    end
  end
end
