require "test_helper"

class Admin::GuestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth = ActionController::HttpAuthentication::Basic.encode_credentials(
      ENV.fetch("ADMIN_USERNAME", "admin"),
      ENV.fetch("ADMIN_PASSWORD", "changeme")
    )
    @welcome = Event.create!(name: "Welcome Dinner", date: Date.new(2026, 9, 11), sort_order: 1)
    @ceremony = Event.create!(name: "Ceremony", date: Date.new(2026, 9, 12), sort_order: 2)
    @group = InviteGroup.create!(name: "The Smiths")
    @guest = @group.guests.create!(first_name: "Dana", last_name: "Smith", attending: true)
  end

  test "edit renders a checkbox for every event" do
    get edit_admin_guest_path(@guest), headers: { "Authorization" => @auth }
    assert_response :success
    assert_select "input[type=checkbox][name*='[attending]'][name*=event_responses_attributes]",
                  count: Event.count
  end

  test "update saves per-event responses" do
    patch admin_guest_path(@guest), headers: { "Authorization" => @auth }, params: {
      guest: {
        attending: "true",
        event_responses_attributes: {
          "0" => { event_id: @welcome.id, attending: "1" },
          "1" => { event_id: @ceremony.id, attending: "0" }
        }
      }
    }
    assert_redirected_to admin_guests_path

    @guest.reload
    assert @guest.event_responses.find_by(event: @welcome).attending
    assert_not @guest.event_responses.find_by(event: @ceremony).attending
  end

  test "update can change an existing per-event response" do
    response = @guest.event_responses.create!(event: @welcome, attending: true)

    patch admin_guest_path(@guest), headers: { "Authorization" => @auth }, params: {
      guest: {
        attending: "true",
        event_responses_attributes: {
          "0" => { id: response.id, event_id: @welcome.id, attending: "0" }
        }
      }
    }
    assert_redirected_to admin_guests_path
    assert_not response.reload.attending
  end
end
