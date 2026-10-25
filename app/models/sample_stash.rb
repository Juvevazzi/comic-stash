# Hard-coded sample collection for the front-end stage.
# Delete this file once the models exist.

module SampleStash
  # A run of a series you collect, e.g. Paper Moons Vol. 2.
  Run = Data.define(:title, :volume, :owned, :total, :gaps, :tone) do
    def missing = total - owned
  end

  # A new or upcoming issue in a series you collect.
  Release = Data.define(:title, :issue, :date_label, :released, :hunting, :tone)

  # Things added to the stash recently.
  RecentSeries = Data.define(:title, :owned, :total, :added_label, :tone)
  RecentComic = Data.define(:title, :issue, :added_label, :tone)

  # Headline numbers for "Your stash in numbers".
  Stats = Data.define(:series_count, :complete_runs, :comic_count, :added_this_month,
                      :longest_run_title, :longest_run_length, :missing_count, :series_with_gaps)

  def self.stats
    Stats.new(series_count: 24, complete_runs: 3, comic_count: 412, added_this_month: 18,
              longest_run_title: "Night Signal", longest_run_length: 48,
              missing_count: 37, series_with_gaps: 9)
  end

  def self.closest_runs
    [
      Run.new(title: "Paper Moons", volume: "Vol. 2", owned: 22, total: 24, gaps: [ "#7", "#19" ], tone: :magenta),
      Run.new(title: "Iron Tide", volume: "Vol. 1", owned: 17, total: 20, gaps: [ "#3", "#11–12" ], tone: :cyan),
      Run.new(title: "Glasshouse", volume: "Vol. 1", owned: 9, total: 12, gaps: [ "#4", "#8", "#10" ], tone: :yellow)
    ]
  end

  def self.releases
    [
      Release.new(title: "Night Signal", issue: "#53", date_label: "Out 14 Oct · not in your stash yet",
                  released: true, hunting: false, tone: :cyan),
      Release.new(title: "Paper Moons", issue: "#25", date_label: "Out 21 Oct",
                  released: false, hunting: false, tone: :magenta),
      Release.new(title: "Static Saints", issue: "#49", date_label: "Out 7 Oct · not in your stash yet",
                  released: true, hunting: true, tone: :yellow)
    ]
  end

  def self.recent_series
    [
      RecentSeries.new(title: "The Long Box Kids", owned: 3, total: 5, added_label: "today", tone: :cyan),
      RecentSeries.new(title: "Glasshouse", owned: 9, total: 12, added_label: "2 days ago", tone: :yellow),
      RecentSeries.new(title: "Hollow Crown", owned: 1, total: 8, added_label: "last week", tone: :magenta)
    ]
  end

  def self.recent_comics
    [
      RecentComic.new(title: "The Long Box Kids", issue: "#3", added_label: "Added today", tone: :cyan),
      RecentComic.new(title: "Glasshouse", issue: "#9", added_label: "Added 2 days ago", tone: :yellow),
      RecentComic.new(title: "Hollow Crown", issue: "#1", added_label: "Added last week", tone: :magenta)
    ]
  end
end
