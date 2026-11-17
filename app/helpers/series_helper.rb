module SeriesHelper
  # Status pill style for a series status: the seeds' words and Metron's.
  # Every pill also shows the word, so the colour is never the only signal.
  def series_status_class(status)
    {
      "Publishing" => "cs-status-owned", "Ongoing" => "cs-status-owned",
      "On hiatus" => "cs-status-hiatus", "Hiatus" => "cs-status-hiatus",
      "Ended" => "cs-status-ended", "Completed" => "cs-status-ended",
      "Cancelled" => "cs-status-upcoming"
    }.fetch(status, "cs-status-ended")
  end
end
