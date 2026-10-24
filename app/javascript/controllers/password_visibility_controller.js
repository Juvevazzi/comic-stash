import { Controller } from "@hotwired/stimulus";

// Toggles the visibility of a password input field when the user clicks the associated button.
export default class extends Controller {
  static targets = ["input", "button"];

  // Toggles the visibility of the password input field and updates the button's aria attributes accordingly.
  toggle() {
    const show = this.inputTarget.type === "password";
    this.inputTarget.type = show ? "text" : "password";
    this.buttonTarget.setAttribute(
      "aria-label",
      show ? "Hide password" : "Show password",
    );
    this.buttonTarget.setAttribute("aria-pressed", show ? "true" : "false");
  }
}
