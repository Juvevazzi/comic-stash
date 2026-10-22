module ApplicationHelper
  # Navbar link that marks itself as the current page: adds .active and
  # aria-current="page" (read out by screen readers).
  #   nav_link_to "Series", series_index_path
  #   nav_link_to "Collection", comics_path, active: controller_name == "comics"
  def nav_link_to(label, path, active: nil, **options)
    active = current_page?(path) if active.nil?
    classes = [ options.delete(:class), ("active" if active) ].compact.join(" ")
    link_to label, path, class: classes, "aria-current": ("page" if active), **options
  end

  # Same idea when the link's content is a block (icon + text), for the tab bar.
  def nav_link_block(path, active: nil, **options, &block)
    active = current_page?(path) if active.nil?
    classes = [ options.delete(:class), ("active" if active) ].compact.join(" ")
    link_to path, class: classes, "aria-current": ("page" if active), **options, &block
  end

  # Bootstrap Icon, hidden from screen readers because the text beside it
  # already says what it means.  icon("plus-lg")
  def icon(name, **options)
    tag.i(class: [ "bi", "bi-#{name}", options.delete(:class) ].compact.join(" "), "aria-hidden": true, **options)
  end
end
