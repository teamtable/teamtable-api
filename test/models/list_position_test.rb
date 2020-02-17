require 'test_helper'

class ListPositionTest < ActiveSupport::TestCase
  def setup
    @list_positions = [list_positions(:one), list_positions(:two), list_positions(:three), list_positions(:four)]
    @list = lists(:one)
    @user = users(:alice)
  end

  test "should be valid" do
    assert @list_positions[0].valid?
  end

  test "save valid list_membership" do
    assert @list_positions[0].save
  end

  test "user_id should be present" do
    @list_positions[0].user_id = nil
    assert_not @list_positions[0].valid?
  end

  test "list_id should be present" do
    @list_positions[0].list_id = nil
    assert_not @list_positions[0].valid?
  end

  test "position should be present" do
    @list_positions[0].list_id = nil
    assert_not @list_positions[0].valid?
  end

  test "list user combination should be unique" do
    duplicate_list_position = @list_positions[0].dup
    duplicate_list_position.position = 5
    @list_positions[0].save
    assert_not duplicate_list_position.valid?

    assert_raise(ActiveRecord::RecordInvalid) do
      ListPosition.create!(
        list_id: duplicate_list_position.list_id,
        user_id: duplicate_list_position.user_id,
        position: duplicate_list_position.position,
      )
    end
  end

  test "user position combination should be unique" do
    duplicate_list_position = @list_positions[0].dup
    duplicate_list_position.list_id = @list_positions[1].list_id
    @list_positions[0].save
    assert_not duplicate_list_position.valid?

    assert_raise(ActiveRecord::RecordInvalid) do
      ListPosition.create!(
        list_id: duplicate_list_position.list_id,
        user_id: duplicate_list_position.user_id,
        position: duplicate_list_position.position,
      )
    end
  end

  test "should delete" do
    if @list_positions[0].save
      @list_positions[0].destroy
      assert @list_positions[0].destroyed?
    end
  end

  test "should be destroyed if the associated list is destroyed" do
    @list_positions[0].list.destroy && assert_raise(ActiveRecord::RecordNotFound) { @list_positions[0].reload }
  end

  test "should be destroyed if the associated user is destroyed" do
    @list_positions[0].user.destroy && assert_raise(ActiveRecord::RecordNotFound) { @list_positions[0].reload }
  end
end
