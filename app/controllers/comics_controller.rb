# Comics. index = View comics, show = View issue, new = Add comics. A "comic"
# here is an issue from the catalogue, so /comics/:id is the issue's id.
# index filters, sorts and pages Stash#issues in the database (TableQuery).
# create, update, bulk and destroy still only redirect back with a message:
class ComicsController < ApplicationController
  include TableQuery

  PER_PAGE = 8

  FILTERS = {
    series: ->(rows, value) { rows.where(series_id: value) },
    issue: ->(rows, value) { rows.where(number: value.strip.delete_prefix("#")) },
    title: ->(rows, value) { rows.where("title ILIKE ?", TableQuery.contains(value)) },
    publisher: ->(rows, value) { rows.where("publisher_name = ?", value) },
    year: ->(rows, value) { rows.where("EXTRACT(YEAR FROM cover_date) = ?", value.to_i) },
    description: ->(rows, value) { rows.where("description ILIKE ?", TableQuery.contains(value)) },
    artist: ->(rows, value) { rows.by_creator(value, role: "Cover") },
    missing: ->(rows, value) { rows.where(value == "yes" ? "stash_status <> 'owned'" : "stash_status = 'owned'") }
  }.freeze

  SORTS = {
    "series" => "series_sort_name", "issue" => "sort_number", "title" => "title",
    "publisher" => "publisher_name", "cover_date" => "cover_date",
    "missing" => "stash_status" # hunting, missing, owned: missing ones first when ascending
  }.freeze

  def index
    stash = Stash.new(Current.user)
    all = stash.issues
    table_query(all.includes(:series), filters: FILTERS, sorts: SORTS, default_sort: "series",
                then_by: "series_sort_name, sort_number, number, id", per_page: PER_PAGE)

    @options = {
      series: stash.series.order(:sort_name).map { |series| [ series.display_name, series.id ] },
      publisher: all.distinct.pluck(:publisher_name).compact.sort,
      year: all.where.not(cover_date: nil).distinct.pluck(Arel.sql("EXTRACT(YEAR FROM cover_date)::integer")).sort.reverse,
      missing: [ [ "Yes", "yes" ], [ "No", "no" ] ]
    }
  end

  # View issue: any issue in the catalogue, with your copy of it if you have one.
  # An unknown id raises RecordNotFound, which Rails turns into the 404 page.
  def show
    @issue = Issue.includes(series: :publisher).find(params[:id])
    @item = Current.user.collection_items.find_by(issue: @issue)
    @previous_issue, @next_issue = @issue.neighbours
    ImportIssueDetailsJob.perform_later(@issue) if @issue.needs_details?
  end

  # Add comics page: the one-comic form, "Added just now" and bulk add.
  def new
    stash = Stash.new(Current.user)
    @series_options = stash.series.order(:sort_name).map do |series|
      [ series.display_name, "#{series.owned_count} of #{series.released_count}" ]
    end
    @just_added = Current.user.collection_items.where(created_at: 1.hour.ago..)
                             .includes(issue: :series).order(created_at: :desc).limit(5)
  end

  # "Add comic". params.expect only lets the three named fields through
  # (strong parameters), which is what the real version will save.
  def create
    comic = params.expect(comic: [ :series_name, :issue_number, :barcode ])
    redirect_to new_comic_path(series: comic[:series_name]),
                notice: "Added. #{comic[:series_name]} ##{comic[:issue_number]} is in your collection."
  end

  # "Got it" and "Remove from collection" (View issue, Find the gaps). Both
  # change one thing, whether you own this comic, so they share the RESTful
  # update action. It returns to the page you came from.
  def update
    issue = Issue.find(params[:id])
    owned = params.expect(comic: [ :owned ])[:owned] == "true"
    flash[:undo] = issue.id if owned # the flash message offers Undo after "Got it"
    redirect_back_or_to comic_path(issue),
                        notice: owned ? "Got it. #{issue} is in your stash." : "Removed. #{issue} is back on your gaps."
  end

  # "Add in bulk": an issue range, a pasted list or a CSV file.
  def bulk
    redirect_to new_comic_path, notice: "Added. Your comics are in your collection."
  end

  # "Undo" in Added just now.
  def destroy
    redirect_to new_comic_path, notice: "Removed from your collection."
  end
end
