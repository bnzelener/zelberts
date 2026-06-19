import { Controller } from "@hotwired/stimulus"

// Toggles the stacked navigation menu on small screens. The menu is always
// visible at the `md` breakpoint and up, so this only matters on mobile.
export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    // Switch from `hidden` to `flex` so the menu becomes a vertical stack on
    // mobile; the `flex-col` and `space-y-*` utilities only apply once the
    // element is actually a flex container.
    this.menuTarget.classList.remove("hidden")
    this.menuTarget.classList.add("flex")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  // Collapse the menu after navigating so it does not stay open across pages.
  close() {
    this.menuTarget.classList.remove("flex")
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }
}
