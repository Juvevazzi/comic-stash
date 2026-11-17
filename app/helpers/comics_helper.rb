module ComicsHelper
  # Two letters for a character chip: "The Operator" -> "TO".
  def initials(name)
    name.split.map { |word| word[0] }.join.first(2).upcase
  end

  # Where a missing issue sits in its series, for the "Your copy" panel.
  def gap_note(previous_issue, next_issue)
    before = previous_issue&.label
    after = next_issue&.label

    if before && after
      "Fills the gap between #{before} and #{after}."
    elsif after
      "Comes before #{after} in this series."
    elsif before
      "Comes after #{before} in this series."
    else
      "The only issue of this series so far."
    end
  end
end
