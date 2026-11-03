# Pages anyone can read without logging in: Help, Terms of use and Privacy.
class PagesController < ApplicationController
  layout "public"

  allow_unauthenticated_access only: %i[help terms privacy]

  HELP_TOPICS = { "start" => "Getting started", "adding" => "Adding comics",
                  "gaps" => "Gaps and hunting", "account" => "Account and data" }.freeze

  # [topic, question, answer]. Content, not data, so it lives with the page.
  FAQ = [
    [ "start", "How do I add my first comic?", "Choose Add comics on the dashboard. Pick a series (or type a new one), enter the issue number and press Add comic. The series stays filled in, so adding the next issue takes seconds." ],
    [ "start", "What does “missing” mean?", "An issue is missing when it has been released in a series you collect, but it is not in your stash. Upcoming issues are never counted as missing." ],
    [ "adding", "Can I add a whole run at once?", "Yes. On the Add comics page, use Add in bulk. You can add an issue range such as #1–12, paste a list, or upload a CSV file." ],
    [ "adding", "Do I need a barcode?", "No. The barcode is optional. If you add the UPC or ISBN printed on the cover, it helps tell variant printings apart." ],
    [ "gaps", "What is the hunt list?", "Your hunt list is the missing issues you are actively looking for. Add an issue with Add to hunt list, then filter Find the gaps to see only those. It is perfect for a trip to the comic shop." ],
    [ "gaps", "I found an issue. How do I tick it off?", "Press Got it next to the issue on Find the gaps, View issue or your search results. It moves into your collection straight away, and you can undo it if you tapped by mistake." ],
    [ "account", "How do I export my collection?", "Go to your profile, then Your data, and choose Export CSV. The file includes every series and issue, with what you own, what is missing and what is on your hunt list." ],
    [ "account", "How do I switch to dark mode?", "Use the moon button in the top bar, or choose Dark under Preferences on your profile. Match my device follows your system setting." ],
    [ "account", "Where does the issue information come from?", "Titles, credits, release dates and covers come from Metron, a community-run comics database. If something looks wrong, you can report it to Metron and the fix will reach Comic Stash." ],
    [ "account", "How do I delete my account?", "On your profile, go to Account and choose Delete account. This permanently removes your account and your whole stash, so export it first if you want a copy." ]
  ].freeze

  # GET /help?q=export&topic=account
  def help
    @q = params[:q].to_s.strip
    @topic = HELP_TOPICS.key?(params[:topic]) ? params[:topic] : nil
    @answers = FAQ.select do |topic, question, answer|
      (@topic.nil? || topic == @topic) &&
        (@q.empty? || "#{question} #{answer}".downcase.include?(@q.downcase))
    end
  end

  def terms
  end

  def privacy
  end
end
