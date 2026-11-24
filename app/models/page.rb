# One page of a database query, for the table pages. It answers the same
# questions a pagination gem such as Pagy would: which rows to show, which
# page this is, and how many pages there are. Two queries: a COUNT, then the
# rows themselves with LIMIT and OFFSET, so only one page is ever loaded.
class Page
  attr_reader :items, :page, :pages, :per, :count

  def initialize(rows, page:, per:)
    @count = rows.count
    @per = per
    @pages = [ (count.to_f / per).ceil, 1 ].max
    @page = page.to_i.clamp(1, pages) # page=0, page=abc or page=99 all land on a real page
    @items = rows.offset((@page - 1) * per).limit(per).to_a
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
