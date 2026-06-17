import { Controller } from "@hotwired/stimulus"

// Reveals the email address field on the RSVP form only when the party opts
// into email updates.
export default class extends Controller {
  static targets = ["field"]

  toggle(event) {
    this.fieldTarget.classList.toggle("hidden", !event.target.checked)
  }
}
