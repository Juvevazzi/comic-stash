# Stands in for Longbox::Metron::Client in the app's tests: it answers from
# JSON files in test/fixtures/files/metron/, never from the network.
# FakeMetron.new(error: SomeError.new) raises that error on every call instead.
class FakeMetron
  attr_reader :calls

  def initialize(error: nil)
    @error = error
    @calls = []
  end

  def series(id) = answer(:series, id) { read("series_#{id}") }
  def series_issues(id) = answer(:series_issues, id) { read("series_#{id}_issues") }
  def issue(id) = answer(:issue, id) { read("issue_#{id}") }
  def search_series(name) = answer(:search_series, name) { read("search_series") }
  private

  def answer(name, id)
    @calls << [ name, id ]
    raise @error if @error

    yield
  end

  def read(name)
    JSON.parse(File.read(Rails.root.join("test/fixtures/files/metron/#{name}.json")))
  end
end
