require "test_helper"

class PublisherTest < ActiveSupport::TestCase
  test "needs a name" do
    assert_not Publisher.new(name: " ").valid?
  end

  test "a Metron id belongs to one publisher only" do
    assert_not Publisher.new(name: "Copy", metron_id: publishers(:lantern).metron_id).valid?
  end

  test "can't be deleted while it still has series" do
    assert_not publishers(:lantern).destroy
    assert Publisher.exists?(publishers(:lantern).id)
  end
end
