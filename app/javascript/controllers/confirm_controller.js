import { Controller } from "@hotwired/stimulus";

// Keeps a dangerous button disabled until a phrase is typed exactly, as in
// "Type delete my stash to confirm". The server checks the phrase too.
export default class extends Controller {
  static targets = ["input", "button"];
  static values = { phrase: String };

  connect() {
    this.check();
  }

  check() {
    const typed = this.inputTarget.value.trim().toLowerCase();
    this.buttonTarget.disabled = typed !== this.phraseValue;
  }
}
