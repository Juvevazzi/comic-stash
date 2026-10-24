import { Controller } from "@hotwired/stimulus";

// This is a Stimulus controller that toggles the theme of the application between light and dark modes
export default class extends Controller {
  connect() {
    this.sync();
  }
  // This method synchronises the theme based on the user's preference stored in localStorage or the system preference
  toggle() {
    const root = document.documentElement;
    const next = root.dataset.bsTheme === "dark" ? "light" : "dark";
    root.dataset.bsTheme = next;
    try {
      localStorage.setItem("theme", next);
    } catch (_) {}

    this.sync();
  }

  sync() {
    const dark = document.documentElement.dataset.bsTheme === "dark";
    this.element.setAttribute("aria-pressed", dark ? "true" : "false");
  }
}
