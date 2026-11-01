module ProfilesHelper
  # A field's classes, plus Bootstrap's is-invalid when the server found a problem with it.
  def field_class(field, base = "form-control")
    [ base, ("is-invalid" if @errors[field]) ].compact.join(" ")
  end

  # ARIA for a field: points to its error message and marks it invalid.
  def field_aria(field, hint = nil)
    ids = [ hint, ("#{field}-error" if @errors[field]) ].compact
    { describedby: ids.join(" ").presence, invalid: (true if @errors[field]) }
  end

  # The error message under a field, if there is one.
  def field_error(field)
    tag.div(@errors[field], id: "#{field}-error", class: "invalid-feedback") if @errors[field]
  end
end
