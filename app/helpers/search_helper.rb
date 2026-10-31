module SearchHelper
  STATUS_PILLS = {
    "owned" => [ "cs-status-owned", "check2", "Owned" ],
    "missing" => [ "cs-status-missing", "dash-circle-dotted", "Missing" ],
    "hunting" => [ "cs-status-hunting", "bookmark-fill", "Hunting" ]
  }.freeze

  # Status pill for an issue: icon and word, never colour alone.
  def status_pill(status)
    css, icon_name, label = STATUS_PILLS.fetch(status)
    tag.span(class: "cs-status #{css}") { safe_join([ icon(icon_name), label ]) }
  end

  # The items a section shows: a preview on the All tab, everything on its own tab.
  def shown(items, section)
    @tab == "all" ? items.first(SearchController::PREVIEW.fetch(section)) : items
  end

  # Link to the same search on another tab, keeping the status chips.
  def search_tab_path(tab)
    search_path({ q: @search.term, tab: tab, status: @statuses.presence }.compact)
  end
end
