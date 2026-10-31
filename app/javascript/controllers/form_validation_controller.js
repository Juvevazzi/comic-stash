import { Controller } from "@hotwired/stimulus";

// Shows Bootstrap's inline error messages using the browser's own checks
// (required, pattern, type). The form needs novalidate so the browser's
// pop-up bubbles don't appear as well. The server must still check again.
export default class extends Controller {
  submit(event) {
    if (!this.element.checkValidity()) {
      event.preventDefault();
      this.element.querySelector(":invalid")?.focus();
    }
    this.element.classList.add("was-validated");
  }

  // After "Clear", hide the messages again.
  reset() {
    this.element.classList.remove("was-validated");
  }
}
