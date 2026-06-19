import { Controller } from "@hotwired/stimulus"

// Toggles the stacked navigation menu on small screens. The menu is always
// visible at the `md` breakpoint and up, so this only matters on mobile.
export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    const isHidden = this.menuTarget.classList.toggle("hidden")
    this.buttonTarget.setAttribute("aria-expanded", String(!isHidden))
  }

  // Collapse the menu after navigating so it does not stay open across pages.
  close() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }
}
