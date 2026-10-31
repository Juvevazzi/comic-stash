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

  # A row of the View series table.
  SeriesRow = Data.define(:name, :began, :ended, :publisher, :series_type, :status, :issue_count, :missing, :tone)

  # A row of the View comics table.
  ComicRow = Data.define(:id, :series, :issue, :title, :publisher, :cover_date, :description, :artists,
                         :missing, :tone)

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

  def self.series_list
    [
      SeriesRow.new(name: "Night Signal", began: 2019, ended: nil, publisher: "Northlight Comics",
                    series_type: "Ongoing series", status: "Publishing", issue_count: 53, missing: 5, tone: :cyan),
      SeriesRow.new(name: "Paper Moons", began: 2022, ended: nil, publisher: "Lantern Press",
                    series_type: "Ongoing series", status: "Publishing", issue_count: 24, missing: 2, tone: :magenta),
      SeriesRow.new(name: "Iron Tide", began: 2021, ended: 2023, publisher: "Halftone House",
                    series_type: "Limited series", status: "Ended", issue_count: 20, missing: 3, tone: :cyan),
      SeriesRow.new(name: "Glasshouse", began: 2023, ended: 2024, publisher: "Lantern Press",
                    series_type: "Limited series", status: "Ended", issue_count: 12, missing: 3, tone: :yellow),
      SeriesRow.new(name: "Static Saints", began: 2016, ended: nil, publisher: "Northlight Comics",
                    series_type: "Ongoing series", status: "Publishing", issue_count: 49, missing: 1, tone: :yellow),
      SeriesRow.new(name: "The Long Box Kids", began: 2025, ended: nil, publisher: "Inkwell",
                    series_type: "Limited series", status: "Publishing", issue_count: 5, missing: 2, tone: :cyan),
      SeriesRow.new(name: "Hollow Crown", began: 2024, ended: 2025, publisher: "Halftone House",
                    series_type: "Limited series", status: "Ended", issue_count: 8, missing: 7, tone: :magenta),
      SeriesRow.new(name: "Brass Lanterns", began: 2014, ended: 2017, publisher: "Inkwell",
                    series_type: "Ongoing series", status: "Cancelled", issue_count: 30, missing: 0, tone: nil),
      SeriesRow.new(name: "Quiet Orbit", began: 2020, ended: 2020, publisher: "Lantern Press",
                    series_type: "One-shot", status: "Ended", issue_count: 1, missing: 0, tone: :magenta),
      SeriesRow.new(name: "Ash and Anchor", began: 2018, ended: 2021, publisher: "Northlight Comics",
                    series_type: "Graphic novel", status: "Ended", issue_count: 3, missing: 0, tone: nil),
      SeriesRow.new(name: "Wolf Hours", began: 2024, ended: nil, publisher: "Halftone House",
                    series_type: "Ongoing series", status: "On hiatus", issue_count: 14, missing: 6, tone: :yellow),
      SeriesRow.new(name: "Velvet Static", began: 2017, ended: 2019, publisher: "Inkwell",
                    series_type: "Limited series", status: "Ended", issue_count: 12, missing: 0, tone: :cyan)
    ]
  end

  def self.comics_list
    [
      ComicRow.new(id: 1, series: "Night Signal", issue: 53, title: "Static on the Line", publisher: "Northlight Comics",
                   cover_date: Date.new(2026, 10, 1), artists: "Mara Quill", missing: true, tone: :cyan,
                   description: "The signal comes back, and this time someone answers it."),
      ComicRow.new(id: 2, series: "Night Signal", issue: 52, title: "Lights Out, Part 4", publisher: "Northlight Comics",
                   cover_date: Date.new(2026, 9, 1), artists: "Mara Quill", missing: true, tone: :magenta,
                   description: "The city goes dark as the four-part blackout story comes to a head."),
      ComicRow.new(id: 3, series: "Night Signal", issue: 48, title: "Relay", publisher: "Northlight Comics",
                   cover_date: Date.new(2026, 4, 1), artists: "Mara Quill, Theo Banks", missing: false, tone: :cyan,
                   description: "A quiet issue about the night shift at the old relay tower."),
      ComicRow.new(id: 4, series: "Paper Moons", issue: 22, title: "The Cartographer", publisher: "Lantern Press",
                   cover_date: Date.new(2026, 8, 1), artists: "Ines Varga", missing: false, tone: :magenta,
                   description: "Juno maps the moons and finds one that should not be there."),
      ComicRow.new(id: 5, series: "Paper Moons", issue: 19, title: "Tidewater", publisher: "Lantern Press",
                   cover_date: Date.new(2026, 3, 1), artists: "Ines Varga", missing: true, tone: :yellow,
                   description: "The tides turn strange when two of the moons line up."),
      ComicRow.new(id: 6, series: "Iron Tide", issue: 12, title: "Breakwater", publisher: "Halftone House",
                   cover_date: Date.new(2023, 6, 1), artists: "Dev Okafor", missing: true, tone: :cyan,
                   description: "The final stand at the harbour wall closes the series."),
      ComicRow.new(id: 7, series: "Iron Tide", issue: 11, title: "Undertow", publisher: "Halftone House",
                   cover_date: Date.new(2023, 5, 1), artists: "Dev Okafor", missing: true, tone: :yellow,
                   description: "The crew is pulled under by a debt they cannot pay."),
      ComicRow.new(id: 8, series: "Iron Tide", issue: 10, title: "Salt", publisher: "Halftone House",
                   cover_date: Date.new(2023, 4, 1), artists: "Dev Okafor, Lu Chen", missing: false, tone: :magenta,
                   description: "A flashback to the first voyage and the storm that started it all."),
      ComicRow.new(id: 9, series: "Glasshouse", issue: 9, title: "Panes", publisher: "Lantern Press",
                   cover_date: Date.new(2024, 9, 1), artists: "Ines Varga", missing: false, tone: :yellow,
                   description: "Every window in the house shows a different year."),
      ComicRow.new(id: 10, series: "Glasshouse", issue: 8, title: "Hairline", publisher: "Lantern Press",
                   cover_date: Date.new(2024, 8, 1), artists: "Ines Varga", missing: true, tone: :cyan,
                   description: "A single crack starts to spread through the greenhouse."),
      ComicRow.new(id: 11, series: "The Long Box Kids", issue: 3, title: "Mint Condition", publisher: "Inkwell",
                   cover_date: Date.new(2026, 7, 1), artists: "Pip Harrow", missing: false, tone: :cyan,
                   description: "The kids track down a perfect copy, and a rival collector."),
      ComicRow.new(id: 12, series: "The Long Box Kids", issue: 2, title: "Bagged and Boarded", publisher: "Inkwell",
                   cover_date: Date.new(2026, 6, 1), artists: "Pip Harrow", missing: false, tone: :magenta,
                   description: "A rainy weekend sorting the shop’s back stock turns up a mystery."),
      ComicRow.new(id: 13, series: "Hollow Crown", issue: 1, title: "Ash Throne", publisher: "Halftone House",
                   cover_date: Date.new(2024, 1, 1), artists: "Theo Banks", missing: false, tone: :magenta,
                   description: "A queen wakes to find her kingdom has forgotten her."),
      ComicRow.new(id: 14, series: "Static Saints", issue: 49, title: "Feedback", publisher: "Northlight Comics",
                   cover_date: Date.new(2026, 10, 1), artists: "Lu Chen, Mara Quill", missing: true, tone: :yellow,
                   description: "The saints play one last show, and the amps answer back.")
    ]
  end
end
