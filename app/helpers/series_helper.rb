module SeriesHelper
  # Status pill style for a series status. Every pill also shows the word,
  # so the colour is never the only signal.
  def series_status_class(status)
    {
      "Publishing" => "cs-status-owned",
      "On hiatus" => "cs-status-hiatus",
      "Ended" => "cs-status-ended",
      "Cancelled" => "cs-status-upcoming"
    }.fetch(status, "cs-status-ended")
  end
end
