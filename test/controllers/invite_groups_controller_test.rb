require "test_helper"

class InviteGroupsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @event = Event.create!(name: "Welcome Dinner", date: Date.new(2026, 9, 11), sort_order: 1)
    @group = InviteGroup.create!(name: "The Smiths")
    @guest = @group.guests.create!(first_name: "Dana", last_name: "Smith")
  end

  def submit_params(email_opt_in:, email:)
    {
      invite_group: {
        email_opt_in: email_opt_in,
        email: email,
        guests_attributes: {
          "0" => {
            id: @guest.id,
            attending: "true",
            event_responses_attributes: {
              "0" => { event_id: @event.id, attending: "true" }
            }
          }
        }
      }
    }
  end

  test "submitting with an email enqueues a confirmation and a host notification" do
    assert_enqueued_emails 2 do
      patch form_invite_group_path(@group), params: submit_params(email_opt_in: "1", email: "smiths@example.com")
    end
    assert_redirected_to invite_group_path(@group)
  end

  test "submitting without opting into email still notifies the host" do
    assert_enqueued_email_with RsvpMailer, :host_notification, args: [ @group ] do
      assert_enqueued_emails 1 do
        patch form_invite_group_path(@group), params: submit_params(email_opt_in: "0", email: "")
      end
    end
    assert_redirected_to invite_group_path(@group)
  end
end
