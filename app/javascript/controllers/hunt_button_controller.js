import { Controller } from "@hotwired/stimulus";

// "Add to hunt list" toggle (shared/_hunt_button).
export default class extends Controller {
  static targets = ["label"];
  static values = { on: Boolean };

  toggle() {
    this.onValue = !this.onValue;
  }

  // Stimulus calls this on connect and every time onValue changes, so the button always matches its value.
  onValueChanged() {
    this.element.setAttribute("aria-pressed", this.onValue ? "true" : "false");
    this.element.classList.toggle("active", this.onValue);
    this.labelTarget.textContent = this.onValue
      ? "On your hunt list"
      : "Add to hunt list";
  }
}
