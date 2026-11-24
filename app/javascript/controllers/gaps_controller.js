import { Controller } from "@hotwired/stimulus";

// Find the gaps: Expand all / Collapse all for the series <details>.
// Without JavaScript each series still opens on its own, so the two buttons
// start hidden and only appear once this controller is running. Show results
// is only needed without JavaScript (auto-submit does its job), so it becomes
// visually hidden: still there for Enter in the search box and screen readers.
export default class extends Controller {
  static targets = ["group", "toggle", "apply"];

  connect() {
    this.toggleTargets.forEach((button) => (button.hidden = false));
    if (this.hasApplyTarget) this.applyTarget.classList.add("visually-hidden");
  }

  expandAll() {
    this.groupTargets.forEach((group) => (group.open = true));
  }

  collapseAll() {
    this.groupTargets.forEach((group) => (group.open = false));
  }
}
