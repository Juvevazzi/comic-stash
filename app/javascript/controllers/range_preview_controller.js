import { Controller } from "@hotwired/stimulus";

// Live preview for the "Issue range" bulk tab: a tile per issue (the first
// 16), a one-line summary, and a submit button that says how many it adds.
export default class extends Controller {
  static targets = [
    "series",
    "from",
    "to",
    "summary",
    "tiles",
    "more",
    "submit",
    "label",
  ];
  static values = {
    max: { type: Number, default: 500 },
    shown: { type: Number, default: 16 },
  };

  connect() {
    this.update();
  }

  update() {
    const series = this.seriesTarget.value.trim();
    const from = parseInt(this.fromTarget.value, 10);
    const to = parseInt(this.toTarget.value, 10);
    const valid =
      series !== "" &&
      Number.isInteger(from) &&
      Number.isInteger(to) &&
      from >= 0 &&
      to >= from;
    const count = valid ? Math.min(to - from + 1, this.maxValue) : 0;

    this.tilesTarget.replaceChildren(
      ...this.tiles(from, Math.min(count, this.shownValue)),
    );
    this.moreTarget.hidden = count <= this.shownValue;
    this.moreTarget.textContent = `and ${count - this.shownValue} more`;
    this.summaryTarget.textContent = valid
      ? `${series} #${from}${to > from ? `–${to}` : ""} · ${this.plural(count)}`
      : "Fill in a series and a range";
    this.labelTarget.textContent = count
      ? `Add ${this.plural(count)}`
      : "Add comics";
    this.submitTarget.disabled = count === 0;
  }

  // Builds the <li> tiles with textContent, never innerHTML, so typed text
  // can't inject markup.
  tiles(from, count) {
    return Array.from({ length: count }, (_, i) => {
      const item = document.createElement("li");
      const tile = document.createElement("span");
      tile.className = "cs-issue is-owned";
      tile.textContent = from + i;
      item.append(tile);
      return item;
    });
  }

  plural(n) {
    return `${n} ${n === 1 ? "comic" : "comics"}`;
  }
}
