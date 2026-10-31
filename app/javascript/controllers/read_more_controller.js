import { Controller } from "@hotwired/stimulus";

// "Read more" for a long description on phones. Without JavaScript the text
// shows in full. With it, the text is cut to four lines, and the button only
// appears when there is more to read.
export default class extends Controller {
  static targets = ["text", "button"];

  connect() {
    this.textTarget.classList.add("cs-clamp");
    const cut = this.textTarget.scrollHeight > this.textTarget.clientHeight;
    this.buttonTarget.hidden = !cut;
    if (!cut) this.textTarget.classList.remove("cs-clamp");
  }

  toggle() {
    const open = !this.textTarget.classList.toggle("cs-clamp");
    this.buttonTarget.setAttribute("aria-expanded", String(open));
    this.buttonTarget.textContent = open ? "Show less" : "Read more";
  }
}
