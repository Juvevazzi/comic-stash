module PagesHelper
  # One numbered section of a legal page. Its number and heading come from
  # the page's contents list, so the list and the sections can't disagree.
  #   <%= legal_section(contents, "data") do %> ... <% end %>
  def legal_section(contents, id, &block)
    number = contents.index { |key, _heading| key == id } + 1
    heading = contents.to_h.fetch(id)

    tag.section(id: id, class: "cs-legal-section", "aria-labelledby": "#{id}-title") do
      title = tag.h2(id: "#{id}-title", class: "h4") do
        safe_join([ tag.span("#{number}.", class: "cs-legal-no"), heading ], " ")
      end
      title + capture(&block)
    end
  end
end
