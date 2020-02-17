require 'test_helper'

class UniqueCardAndListIdsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    log_in_as @user
    @project = projects(:one)
    @list = lists(:one)
  end

  test "ids should be unique within cards and lists" do
    id = 980_191_000
    100.times do
      id += 1
      list = List.create!(id: id, title: "Title", project: @project, created_by: @user)
      card = Card.create!(id: id, title: "Title", list: @list, created_by: @user)
      assert list.id != card.id
    end
  end
end
