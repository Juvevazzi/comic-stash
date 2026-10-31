import { Controller } from "@hotwired/stimulus";

// Live preview for the "Paste a list" bulk tab. Each line is
// "series, issue, barcode" (barcode optional). Lines with a problem are
// flagged and left out of the count. The server will check them again.
export default class extends Controller {
  static targets = ["input", "rows", "summary", "note", "submit", "label"];

  connect() {
    this.update();
  }

  update() {
    const lines = this.inputTarget.value
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);
    const rows = lines.map((line) => this.parse(line));
    const ready = rows.filter((row) => !row.problem).length;

    this.rowsTarget.replaceChildren(...rows.map((row) => this.row(row)));
    this.summaryTarget.textContent = `${ready} of ${rows.length} ready`;
    this.noteTarget.textContent =
      ready < rows.length
        ? "Lines with a problem are skipped. Fix them to include them."
        : "You can undo any of these from “Added just now”.";
    this.labelTarget.textContent = ready
      ? `Add ${ready} ${ready === 1 ? "comic" : "comics"}`
      : "Add comics";
    this.submitTarget.disabled = ready === 0;
  }

  // "Iron Tide, #11, 761..." -> { series, issue, barcode, problem }
  parse(line) {
    const [series = "", rawIssue = "", barcode = ""] = line
      .split(",")
      .map((part) => part.trim());
    const issue = rawIssue.replace(/^#/, "");
    let problem = null;
    if (!series) problem = "Needs a series name";
    else if (!issue) problem = "Needs an issue number";
    else if (!/^[0-9]+$/.test(issue)) problem = "Issue must be a number";
    else if (barcode && !/^[0-9]+$/.test(barcode))
      problem = "Barcode must be digits";
    return { series, issue, barcode, problem };
  }

  // One preview table row, built with textContent so pasted text stays text.
  row({ series, issue, barcode, problem }) {
    const tr = document.createElement("tr");
    tr.append(
      this.cell(series || "—"),
      this.cell(issue ? `#${issue}` : "—"),
      this.cell(barcode || "—"),
      this.cell(this.status(problem)),
    );
    return tr;
  }

  cell(content) {
    const td = document.createElement("td");
    td.append(content);
    return td;
  }

  // Status pill: always an icon and words, never colour alone.
  status(problem) {
    const pill = document.createElement("span");
    pill.className = `cs-status ${problem ? "cs-status-problem" : "cs-status-owned"}`;
    const icon = document.createElement("i");
    icon.className = `bi ${problem ? "bi-exclamation-circle" : "bi-check2"}`;
    icon.setAttribute("aria-hidden", "true");
    pill.append(icon, problem || "Ready");
    return pill;
  }
}
