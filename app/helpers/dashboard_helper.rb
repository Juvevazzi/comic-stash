module DashboardHelper
  # Under a release: "Out 14 Oct · not in your stash yet", or "Out 21 Nov"
  # for one that isn't out yet.
  def release_note(issue)
    date = issue.released_on.strftime("%-d %b")
    issue.released? ? "Out #{date} · not in your stash yet" : "Out #{date}"
  end
end
