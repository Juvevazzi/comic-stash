module Longbox
  # One run of a series: every issue released so far and the ones you own.
  # It answers the questions Comic Stash asks on every page: how many do I
  # have, what's missing, and how would I write the gaps on a shopping list.
  #
  #   run = Longbox::Run.new(released: 1..12, owned: [ 1, 2, 3, 5, 9, 10, 12 ])
  #   run.gaps     # => ["#4", "#6–8", "#11"]
  #   run.percent  # => 58
  class Run
    attr_reader :released, :owned

    def initialize(released:, owned:)
      @released = released.map { |number| IssueNumber.new(number) }.uniq.sort
      have = owned.map { |number| IssueNumber.new(number) }.to_set
      # Only count owned issues that are part of the run (not variants or
      # issues the catalogue doesn't know yet).
      @owned = @released.select { |number| have.include?(number) }
    end

    # The runs you're closest to finishing: unfinished ones, fewest missing
    # first, then the highest percentage. Used for "Closest to complete".
    def self.closest(runs, limit: 3)
      runs.reject { |run| run.complete? || run.owned_count.zero? }
          .sort_by { |run| [ run.missing_count, -run.percent ] }
          .first(limit)
    end

    def total = released.size
    def owned_count = owned.size
    def missing = released - owned
    def missing_count = missing.size
    def complete? = total.positive? && missing.empty?

    # Whole-number percentage, rounded down so 99.6% never shows as 100%.
    def percent
      total.zero? ? 0 : owned_count * 100 / total
    end

    # Missing issues as short labels, with neighbours joined into a range:
    # ["#3", "#11–12"]. Neighbours means next to each other in the run, so
    # a series that skips a number still reads naturally.
    def gaps
      released.slice_when { |a, b| owned?(a) != owned?(b) }
              .reject { |stretch| owned?(stretch.first) }
              .map { |stretch| range_label(stretch) }
    end

    private

    def owned?(number) = owned.include?(number)

    def range_label(stretch)
      return stretch.first.label if stretch.one?

      "#{stretch.first.label}–#{stretch.last}"
    end
  end
end
