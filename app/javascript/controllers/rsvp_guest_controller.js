import { Controller } from "@hotwired/stimulus"

// One instance per guest card on the RSVP form. Shows the follow-up questions
// (events, dietary, plus-one) only when the guest is marked attending, and
// reveals the plus-one name field when "bringing a guest" is checked.
export default class extends Controller {
  static targets = ["followups", "plusOneFields"]

  toggle(event) {
    const attending = event.target.value === "true"
    this.followupsTarget.classList.toggle("hidden", !attending)
  }

  togglePlusOne(event) {
    if (!this.hasPlusOneFieldsTarget) return
    this.plusOneFieldsTarget.classList.toggle("hidden", !event.target.checked)
  }
}
