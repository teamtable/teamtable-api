require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  def setup
    @assignment = assignments(:one)
    @card = cards(:one)
    @user = users(:alice)
  end

  test "should be valid" do
    assert @assignment.valid?
  end

  test "save valid assignment" do
    assert @assignment.save
  end

  test "user_id should be present" do
    @assignment.user_id = nil
    assert_not @assignment.valid?
  end

  test "card_id should be present" do
    @assignment.card_id = nil
    assert_not @assignment.valid?
  end

  test "should delete" do
    if @assignment.save
      @assignment.destroy
      assert @assignment.destroyed?
    end
  end
end
