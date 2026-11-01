import { Controller } from "@hotwired/stimulus";

// Light, Dark or Match my device on your profile. The theme itself lives in
// the browser (localStorage, read by the script in layouts/_head), so this
// ticks the option that's really in use and applies a new choice at once.
export default class extends Controller {
  static targets = ["choice"];

  connect() {
    let saved = null;
    try {
      saved = localStorage.getItem("theme");
    } catch (_) {}
    const current = saved || "system";
    this.choiceTargets.forEach(
      (radio) => (radio.checked = radio.value === current),
    );
  }

  apply(event) {
    const choice = event.target.value;
    const systemDark = window.matchMedia(
      "(prefers-color-scheme: dark)",
    ).matches;
    const dark = choice === "dark" || (choice === "system" && systemDark);
    document.documentElement.dataset.bsTheme = dark ? "dark" : "light";
    try {
      if (choice === "system") localStorage.removeItem("theme");
      else localStorage.setItem("theme", choice);
    } catch (_) {}
  }
}
