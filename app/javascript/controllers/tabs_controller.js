import { Controller } from "@hotwired/stimulus";

// Accessible tabs (the WAI-ARIA tabs pattern). Click a tab, or use the
// Left/Right arrow keys and Home/End, to show its panel. Tabs and panels are
// paired by position, so the first tab shows the first panel.
export default class extends Controller {
  static targets = ["tab", "panel"];

  select(event) {
    this.show(this.tabTargets.indexOf(event.currentTarget));
  }

  move(event) {
    const count = this.tabTargets.length;
    const current = this.tabTargets.indexOf(event.currentTarget);
    const next = {
      ArrowRight: current + 1,
      ArrowLeft: current - 1,
      Home: 0,
      End: count - 1,
    }[event.key];
    if (next === undefined) return;

    event.preventDefault();
    const index = (next + count) % count; // wrap around at either end
    this.show(index);
    this.tabTargets[index].focus();
  }

  show(index) {
    this.tabTargets.forEach((tab, i) => {
      const selected = i === index;
      tab.setAttribute("aria-selected", selected ? "true" : "false");
      tab.tabIndex = selected ? 0 : -1; // only the open tab is in the Tab order
      this.panelTargets[i].hidden = !selected;
    });
  }
}
