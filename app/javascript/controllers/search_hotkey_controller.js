import { Controller } from "@hotwired/stimulus";

// This is a Stimulus controller that listens for the "/" key press and focuses on the search input field, unless the user is currently typing in an input, textarea, select, or contenteditable element.
export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.onKey = this.onKey.bind(this);
    document.addEventListener("keydown", this.onKey);
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey);
  }

  // Checks if the pressed key is "/" and if the user is not currently typing. If both conditions are met, it prevents the default action and focuses on the search input field.
  onKey(event) {
    if (event.key !== "/" || event.metaKey || event.ctrlKey || event.altKey)
      return;
    if (event.target.closest("input, textarea, select, [contenteditable]"))
      return;
    event.preventDefault();
    this.inputTarget.focus();
  }
}
