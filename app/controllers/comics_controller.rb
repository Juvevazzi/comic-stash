# Comics. index = View comics, show = View issue, new = Add comics. A "comic"
# here is an issue from the catalogue, so /comics/:id is the issue's id.
# index filters, sorts and pages Stash#issues in the database (TableQuery).
# create, bulk, update and destroy save to your own stash (Current.user).
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
    @issue = Issue.visible_to(Current.user).includes(series: :publisher).find(params[:id])
    @item = Current.user.collection_items.find_by(issue: @issue)
    @previous_issue, @next_issue = @issue.neighbours(Current.user)
    ImportIssueDetailsJob.perform_later(@issue) if @issue.needs_details?
  end

  # Add comics page: the one-comic form, "Added just now" and bulk add.
  def new
    stash = Stash.new(Current.user)
    mine = stash.series.order(:sort_name).map do |series|
      [ series.display_name, "#{series.owned_count} of #{series.released_count}" ]
    end
    # Imported series you don't collect yet, so a new import can be picked straight away.
    catalogue = Series.where.not(metron_id: nil).where.not(id: stash.series.select(:id))
                      .order(:sort_name).limit(300)
                      .map { |series| [ series.display_name, "In the catalogue" ] }
    @series_options = mine + catalogue
    @just_added = Current.user.collection_items.where(created_at: 1.hour.ago..)
                             .includes(issue: :series).order(created_at: :desc).limit(5)
  end

  # "Add comic": strong parameters (params.expect) let only the three named
  # fields through. AddComics finds or makes the series and issue.
  def create
    comic = params.expect(comic: [ :series_name, :issue_number, :barcode ])
    item = AddComics.new(Current.user).add(series_name: comic[:series_name], number: comic[:issue_number],
                                           barcode: comic[:barcode])
    redirect_to new_comic_path(series: comic[:series_name]), notice: "Added. #{item.issue} is in your collection."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to new_comic_path(series: comic[:series_name]),
                alert: "Nothing was added: #{error.record.errors.full_messages.to_sentence}."
  end

  # "Got it" and "Remove from collection" (View issue, Find the gaps, Search,
  # the dashboard). Both change one thing, whether you own this issue, so they
  # share the RESTful update action, and come back to the page you were on.
  def update
    issue = Issue.visible_to(Current.user).find(params[:id])
    if params.expect(comic: [ :owned ])[:owned] == "true"
      Current.user.collect!(issue)
      flash[:undo] = issue.id # the message offers Undo
      notice = "Got it. #{issue} is in your stash."
    else
      Current.user.uncollect!(issue)
      notice = "Removed. #{issue} is back on your gaps."
    end
    redirect_back_or_to comic_path(issue), notice: notice
  end

  # "Add in bulk": an issue range, a pasted list or a CSV file. All or nothing.
  def bulk
    bulk = params.expect(bulk: [ :source, :series_name, :from, :to, :list, :file ])
    rows = case bulk[:source]
    when "range" then AddComics.range(bulk[:series_name], bulk[:from], bulk[:to])
    when "paste" then AddComics.parse_lines(bulk[:list])
    when "csv" then AddComics.parse_csv(bulk[:file]&.read)
    else []
    end
    result = AddComics.new(Current.user).add_all(rows)

    if result.problems.any?
      redirect_to new_comic_path, alert: "Nothing was added. #{result.problems.first(3).join(" ")}"
    else
      redirect_to new_comic_path, notice: "Added #{result.added.size} #{"comic".pluralize(result.added.size)} to your collection."
    end
  end

  # "Undo" in Added just now.
  def destroy
    issue = Issue.visible_to(Current.user).find(params[:id])
    Current.user.uncollect!(issue)
    redirect_to new_comic_path, notice: "Removed #{issue} from your collection."
  end
end
