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

  # A comic you just added (the "Added just now" list on Add comics).
  Addition = Data.define(:id, :title, :issue, :barcode, :added_label, :tone)

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
  # Series in your stash, offered as you type a series name: [name, how many you own].
  def self.series_options
    [
      [ "Night Signal", "48 of 52" ], [ "Paper Moons", "22 of 24" ], [ "Iron Tide", "17 of 20" ],
      [ "Glasshouse", "9 of 12" ], [ "Static Saints", "48 issues" ], [ "The Long Box Kids", "3 of 5" ],
      [ "Hollow Crown", "1 of 8" ]
    ]
  end

  def self.just_added
    [
      Addition.new(id: 1, title: "Paper Moons", issue: "#22", barcode: "76194134182502211", added_label: "2 min ago", tone: :magenta),
      Addition.new(id: 2, title: "Glasshouse", issue: "#9", barcode: nil, added_label: "5 min ago", tone: :yellow)
    ]
  end

  # One issue in full, for View issue. The fields from comics_list change from
  # issue to issue; the rest are the same sample extras on every issue until
  # the Metron import supplies the real ones.
  Issue = Data.define(:id, :series, :issue, :title, :publisher, :cover_date, :store_date, :price, :pages,
                      :arc, :arc_part, :tags, :description, :characters, :credits, :cover_artists, :editors,
                      :upc, :metron_id, :owned, :added_on, :hunting, :tone, :previous_issue, :next_issue)

  BLURB = "Back issues, long boxes and one stubborn gap: this is the issue collectors argue about. " \
          "Read it for the art, keep it for the cover, and do not lend it to anyone."

  # Finds a comic by id like Comic.find will: an unknown id raises
  # RecordNotFound, which Rails turns into a 404 page.
  def self.issue(id)
    comic = all_comics.find { |row| row.id == id.to_i }
    raise ActiveRecord::RecordNotFound, "No sample comic with id #{id}" unless comic

    # The other issues of this series in your stash, in number order.
    run = all_comics.select { |row| row.series == comic.series }.sort_by(&:issue)
    place = run.index(comic)

    # "Lights Out, Part 4" -> story arc "Lights Out", part 4.
    arc_name, arc_part = comic.title.match(/\A(.+), Part (\d+)\z/)&.captures

    Issue.new(
      id: comic.id, series: comic.series, issue: comic.issue, title: comic.title,
      publisher: comic.publisher, cover_date: comic.cover_date, tone: comic.tone,
      description: "#{comic.description} #{BLURB}",
      owned: !comic.missing, hunting: HUNTING.include?(comic.id), added_on: Date.new(2026, 10, 12),
      store_date: comic.cover_date - 2.months + 5.days, price: 3.99, pages: 32,
      arc: arc_name, arc_part: arc_part&.to_i,
      tags: [ "Single issue", "Mystery", "Rated Teen", "English" ],
      characters: [ "Juno Vale", "The Operator", "Marlo Finch" ],
      credits: [ [ "Writer", "Ada Moreno" ], [ "Artist", comic.artists ], [ "Colorist", "Priya Shah" ],
                 [ "Letterer", "Tom Ellery" ] ],
      cover_artists: [ *comic.artists.split(", "), "Kit Hale" ],
      editors: [ [ "Editor", "June Park" ], [ "Group Editor", "Sam Ortiz" ], [ "Editor in Chief", "Lena Brook" ] ],
      upc: "761941#{comic.id.to_s.rjust(5, "0")}00111", metron_id: 129_000 + comic.id,
      previous_issue: (run[place - 1] if place.positive?), next_issue: run[place + 1]
    )
  end

  # Find the gaps: one group per series with gaps, holding its missing issues.
  GapGroup = Data.define(:name, :meta, :owned, :total, :tone, :issues)
  GapIssue = Data.define(:id, :issue, :title, :cover_date, :artists, :hunting)

  # Missing issues that aren't in comics_list, so every gap in series_list
  # has an issue behind it: [series, number, title, cover date, cover artist].
  EXTRA_GAPS = [
    [ "Night Signal", 49, "Dead Air", Date.new(2026, 5, 1), "Mara Quill" ],
    [ "Night Signal", 50, "Fifty Frequencies", Date.new(2026, 6, 1), "Mara Quill, Theo Banks" ],
    [ "Night Signal", 51, "Lights Out, Part 1", Date.new(2026, 7, 1), "Mara Quill" ],
    [ "Paper Moons", 7, "Waning", Date.new(2023, 8, 1), "Ines Varga" ],
    [ "Iron Tide", 3, "Ballast", Date.new(2022, 8, 1), "Dev Okafor" ],
    [ "Glasshouse", 4, "Condensation", Date.new(2024, 4, 1), "Ines Varga" ],
    [ "Glasshouse", 10, "Frost Line", Date.new(2024, 10, 1), "Ines Varga" ],
    [ "The Long Box Kids", 4, "Variant Hunters", Date.new(2026, 8, 1), "Pip Harrow" ],
    [ "The Long Box Kids", 5, "Back Issue Bin", Date.new(2026, 9, 1), "Pip Harrow" ],
    [ "Hollow Crown", 2, "Cinders", Date.new(2024, 2, 1), "Theo Banks" ],
    [ "Hollow Crown", 3, "The Regent", Date.new(2024, 3, 1), "Theo Banks" ],
    [ "Hollow Crown", 4, "Bone Orchard", Date.new(2024, 4, 1), "Theo Banks" ],
    [ "Hollow Crown", 5, "Usurper", Date.new(2024, 5, 1), "Theo Banks" ],
    [ "Hollow Crown", 6, "A Court of Moths", Date.new(2024, 6, 1), "Theo Banks" ],
    [ "Hollow Crown", 7, "Last Rites", Date.new(2024, 7, 1), "Theo Banks" ],
    [ "Hollow Crown", 8, "Crowned", Date.new(2024, 8, 1), "Theo Banks" ],
    [ "Wolf Hours", 3, "Moonrise", Date.new(2024, 5, 1), "Dev Okafor" ],
    [ "Wolf Hours", 5, "Tracks", Date.new(2024, 7, 1), "Dev Okafor" ],
    [ "Wolf Hours", 9, "The Long Night", Date.new(2024, 11, 1), "Lu Chen" ],
    [ "Wolf Hours", 10, "Pack", Date.new(2024, 12, 1), "Dev Okafor" ],
    [ "Wolf Hours", 11, "Howl", Date.new(2025, 1, 1), "Dev Okafor" ],
    [ "Wolf Hours", 14, "Daybreak", Date.new(2025, 4, 1), "Dev Okafor" ]
  ].freeze

  # Ids of the missing issues on your hunt list: Iron Tide #11, Static Saints #49, Paper Moons #7.
  HUNTING = [ 7, 14, 18 ].freeze

  # EXTRA_GAPS as ComicRows, numbered on from comics_list (ids 15 to 36).
  def self.extra_gaps
    EXTRA_GAPS.each_with_index.map do |(series, number, title, cover_date, artists), index|
      info = series_list.find { |row| row.name == series }
      ComicRow.new(id: 15 + index, series: series, issue: number, title: title, publisher: info.publisher,
                   cover_date: cover_date, artists: artists, missing: true, tone: info.tone,
                   description: "#{title}: the full solicitation arrives with the Metron import.")
    end
  end

  # Every sample comic: your list plus the extra missing issues.
  def self.all_comics
    comics_list + extra_gaps
  end

  # One GapGroup per series that has gaps, its missing issues in number order.
  def self.gap_groups
    missing = all_comics.select(&:missing)

    series_list.select { |series| series.missing.positive? }.map do |series|
      issues = missing.select { |comic| comic.series == series.name }.sort_by(&:issue).map do |comic|
        GapIssue.new(id: comic.id, issue: comic.issue, title: comic.title, cover_date: comic.cover_date,
                     artists: comic.artists, hunting: HUNTING.include?(comic.id))
      end

      GapGroup.new(name: series.name, tone: series.tone, issues: issues,
                   owned: series.issue_count - series.missing, total: series.issue_count,
                   meta: "#{series.series_type} · #{series.began}–#{series.ended || "present"} · #{series.publisher}")
    end
  end
end
