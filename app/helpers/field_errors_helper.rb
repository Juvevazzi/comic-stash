# Server-side validation messages on form fields, used by sign up, the
# password pages and the profile form. A controller puts field => message
# in @errors; pages without @errors simply show no errors.
module FieldErrorsHelper
  # A field's classes, plus Bootstrap's is-invalid when it has an error.
  def field_class(field, base = "form-control")
    [ base, ("is-invalid" if field_errors[field]) ].compact.join(" ")
  end

  # ARIA for a field: points to its hint and error message, and marks it invalid.
  def field_aria(field, hint = nil)
    ids = [ hint, ("#{field}-error" if field_errors[field]) ].compact
    { describedby: ids.join(" ").presence, invalid: (true if field_errors[field]) }
  end

  # The error message under a field, if there is one. d-block shows it even
  # when it isn't right after the input (the password field has a button in between).
  def field_error(field)
    tag.div(field_errors[field], id: "#{field}-error", class: "invalid-feedback d-block") if field_errors[field]
  end

  private

  def field_errors = @errors || {}
end
