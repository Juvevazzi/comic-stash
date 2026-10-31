import { Controller } from "@hotwired/stimulus";

// Re-runs a filter form as soon as one of its fields changes, so there is no
// "Apply" button to press. Each field calls this through
// data-action="change->auto-submit#submit". field.form finds the field's own
// form, even when the field sits outside it and joins through form="...".
export default class extends Controller {
  submit(event) {
    event.target.form?.requestSubmit();
  }
}
