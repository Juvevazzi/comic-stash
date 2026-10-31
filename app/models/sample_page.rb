# One page of rows from an in-memory list, for the front-end stage.
# It answers the same questions a pagination gem such as Pagy will:
# which rows to show, which page this is, and how many pages there are.
class SamplePage
  attr_reader :items, :page, :pages, :per, :count

  def initialize(rows, page:, per:)
    @count = rows.size
    @per = per
    @pages = [ (count.to_f / per).ceil, 1 ].max
    @page = page.to_i.clamp(1, pages) # page=0, page=abc or page=99 all land on a real page
    @items = rows.slice((@page - 1) * per, per) || []
  end

  def first? = page == 1
  def last? = page == pages

  # Page numbers to link to, with nil where a "…" goes: 1 … 4 5 6 … 32
  def window
    numbers = [ 1, page - 1, page, page + 1, pages ].select { |n| n.between?(1, pages) }.uniq
    numbers.each_with_object([]) do |number, list|
      list << nil if list.any? && number > list.last + 1
      list << number
    end
  end
end
