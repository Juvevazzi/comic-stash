# Demo data for development: one user with a stash across four series. No
# network needed (bin/ci runs the seeds too), and safe to run again, since
# everything is find-or-create.
#
#   bin/rails db:seed    then log in as demo@comicstash.test / comics123
#
# For real series from Metron, use bin/rails "metron:import[ID]" instead.
return if Rails.env.production?

demo = User.find_or_create_by!(email_address: "demo@comicstash.test") do |user|
  user.name = "Demo Collector"
  user.password = "comics123"
  user.terms_accepted = "1"
end

lantern = Publisher.find_or_create_by!(name: "Lantern Press")
northlight = Publisher.find_or_create_by!(name: "Northlight Comics")
halftone = Publisher.find_or_create_by!(name: "Halftone House")

# name, volume, publisher, began, ended, issues out, missing, hunting
runs = [
  [ "Paper Moons", 2, lantern, 2022, nil, 24, [ 7, 19 ], [ 7 ] ],
  [ "Iron Tide", 1, halftone, 2021, 2023, 20, [ 3, 11, 12 ], [ 11 ] ],
  [ "Glasshouse", 1, lantern, 2023, 2024, 12, [ 4, 8, 10 ], [] ],
  [ "Night Signal", 1, northlight, 2019, nil, 53, [ 49, 50, 51, 52, 53 ], [ 53 ] ]
]

runs.each do |name, volume, publisher, began, ended, out, missing, hunting|
  series = Series.find_or_create_by!(name: name, volume: volume) do |new_series|
    new_series.publisher = publisher
    new_series.year_began = began
    new_series.year_end = ended
    new_series.series_type = ended ? "Limited series" : "Ongoing series"
    new_series.status = ended ? "Ended" : "Publishing"
    new_series.issue_count = out
  end

  # One issue a month up to last month, and the next one due next month
  # if the series is still going.
  (1..out).each do |number|
    series.issues.find_or_create_by!(number: number.to_s) do |issue|
      issue.store_date = (out - number + 1).months.ago.to_date
    end
  end
  unless ended
    series.issues.find_or_create_by!(number: (out + 1).to_s) { |issue| issue.store_date = 1.month.from_now.to_date }
  end

  # Own everything released except the gaps; some gaps are on the hunt list.
  series.issues.released.each do |issue|
    number = issue.number.to_i
    next if missing.include?(number) && !hunting.include?(number)

    status = hunting.include?(number) ? :hunting : :owned
    demo.collection_items.find_or_create_by!(issue: issue) { |item| item.status = status }
  end
end

puts "Seeded #{demo.email_address}: #{demo.owned_issues.count} comics owned, #{demo.hunted_issues.count} on the hunt list."
