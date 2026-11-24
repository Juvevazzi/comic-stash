module Longbox
  # An issue number as printed on the cover: "1", "12", "1.5", "½", "1.MU".
  # Comic numbers are text, not integers, but they still need to sort the way
  # a collector expects: 2 before 10, decimals in between, odd ones last.
  class IssueNumber
    include Comparable

    attr_reader :to_s

    def initialize(value)
      @to_s = value.to_s.strip.delete_prefix("#")
      raise ArgumentError, "an issue number can't be blank" if @to_s.empty?
    end

    # Sort by the number at the start ("12" in "12.MU"), then by the text.
    # Numbers with no leading digits ("½") go after all the others.
    def <=>(other)
      sort_key <=> other.sort_key if other.is_a?(IssueNumber)
    end

    # Two IssueNumbers are the same issue when their text matches, so they
    # work as Hash keys and in Sets (uniq, include?).
    def eql?(other) = other.is_a?(IssueNumber) && to_s == other.to_s
    def hash = to_s.hash

    def label = "##{self}"

    protected

    def sort_key
      lead = to_s[/\A\d+(?:\.\d+)?/]
      [ lead ? 0 : 1, lead ? lead.to_r : 0, to_s ]
    end
  end
end
