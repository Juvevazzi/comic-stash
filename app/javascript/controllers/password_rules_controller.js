import { Controller } from "@hotwired/stimulus";

// Checks the password input field against a set of rules and updates the UI to indicate which rules are met.
export default class extends Controller {
  static targets = ["input", "rule"];

  connect() {
    this.check();
  }

  // Checks the password input field against the defined rules and updates the UI to indicate which rules are met.
  check() {
    const value = this.inputTarget.value;
    this.ruleTargets.forEach((rule) => {
      rule.classList.toggle(
        "is-met",
        new RegExp(rule.dataset.pattern).test(value),
      );
    });
  }
}
