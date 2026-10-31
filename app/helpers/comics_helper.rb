module ComicsHelper
  # Two letters for a character chip: "The Operator" -> "TO".
  def initials(name)
    name.split.map { |word| word[0] }.join.first(2).upcase
  end

  # Where a missing issue sits in your run, for the "Your copy" panel.
  def gap_note(issue)
    before = issue.previous_issue&.issue
    after = issue.next_issue&.issue

    if before && after
      "Fills the gap between ##{before} and ##{after}."
    elsif after
      "Comes before ##{after} in your run."
    elsif before
      "Comes after ##{before} in your run."
    else
      "The first issue of this series in your stash."
    end
  end
end
