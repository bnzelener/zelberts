require "test_helper"
require "csv"

class Admin::GuestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @headers = {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
        ENV.fetch("ADMIN_USERNAME", "admin"), ENV.fetch("ADMIN_PASSWORD", "changeme")
      )
    }

    @group = InviteGroup.create!(name: "The Zelberts", email: "z@example.com", weecasa_included: true,
                                 weecasa_response: true, email_opt_in: true)
    @event = Event.create!(name: "Welcome Dinner", date: Date.new(2026, 9, 11), sort_order: 10)
    @guest = Guest.create!(invite_group: @group, first_name: "Ada", last_name: "Zelbert",
                           phone: "555-0100", dietary_notes: "No shellfish",
                           plus_one_allowed: true, plus_one: true,
                           plus_one_first_name: "Grace", plus_one_last_name: "Hopper",
                           attending: true)
    @guest.event_responses.create!(event: @event, attending: true)
  end

  test "index offers the CSV download" do
    get admin_guests_path, headers: @headers

    assert_response :success
    assert_select "a[href=?]", export_admin_guests_path(format: :csv), text: /Download CSV/
  end

  test "export returns a CSV attachment covering every guest" do
    get export_admin_guests_path(format: :csv), headers: @headers

    assert_response :success
    assert_match "text/csv", response.media_type
    assert_match(/attachment; filename="guests-\d{4}-\d{2}-\d{2}\.csv"/, response.headers["Content-Disposition"])

    rows = CSV.parse(response.body, headers: true)
    assert_includes rows.headers, "Welcome Dinner"

    host = rows.find { |r| r["First name"] == "Ada" }
    assert_equal "The Zelberts", host["Group"]
    assert_equal "z@example.com", host["Group email"]
    assert_equal "555-0100", host["Phone"]
    assert_equal "Attending", host["Status"]
    assert_equal "No shellfish", host["Dietary notes"]
    assert_equal "Grace Hopper", host["Plus one"]
    assert_equal "Yes", host["WeeCasa included"]
    assert_equal "Yes", host["WeeCasa response"]
    assert_equal "Yes", host["Email opt-in"]
    assert_equal "Yes", host["Welcome Dinner"]

    plus_one = rows.find { |r| r["First name"] == "Grace" }
    assert_equal "Ada Zelbert", plus_one["Plus one of"]

    # Fixture guests (no group, no response) come along with blanks, not errors.
    pending = rows.find { |r| r["Status"] == "Pending" || r["Group"].nil? }
    assert_not_nil pending
  end

  test "export honors the search query" do
    get export_admin_guests_path(format: :csv, q: "Zelbert"), headers: @headers

    names = CSV.parse(response.body, headers: true).map { |r| r["Last name"] }
    assert_includes names, "Zelbert"
    assert_equal [ "Zelbert" ], names.uniq
  end
end
