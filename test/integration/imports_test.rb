require "test_helper"

# Import from Metron, against FakeMetron: searching lists Glasshouse (501)
# and Paper Moons (2001, already in the catalogue as a fixture).
class ImportsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    sign_in_as users(:ricardo)
    MetronImport.client = FakeMetron.new
  end

  teardown { MetronImport.client = nil }

  test "searching lists Metron's series and marks the ones already here" do
    get new_import_path(q: "glass")
    assert_response :success
    assert_select "ul[aria-label='Series on Metron'] li", 2
    assert_select "button[aria-label=?]", "Import Glasshouse (2023)"
    assert_select "li", text: /Paper Moons \(2022\).*In the catalogue/m
  end

  test "Add comics links to Import from Metron" do
    get new_comic_path
    assert_select "a[href=?]", new_import_path
  end

  test "import queues the job and comes straight back" do
    assert_enqueued_with(job: ImportSeriesJob, args: [ 501 ]) do
      post imports_path, params: { metron_id: "501" }
    end
    assert_redirected_to new_import_path
  end

  test "Metron being down is a message, not an error page" do
    MetronImport.client = FakeMetron.new(error: Longbox::Metron::ServerError.new("down"))
    get new_import_path(q: "glass")
    assert_response :success
    assert_select ".alert-danger", /Metron isn't answering/
  end
end
