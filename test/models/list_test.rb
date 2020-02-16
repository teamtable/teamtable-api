require 'test_helper'

class ListTest < ActiveSupport::TestCase
  def setup
    @list = lists(:one)
  end

  test "should be valid" do
    assert @list.valid?
  end

  test "save valid list" do
    assert @list.save
  end

  test "title should be present" do
    @list.title = "     "
    assert_not @list.valid?
  end

  test "created_by should be present" do
    @list.created_by = nil
    assert_not @list.valid?
  end

  test "description should not be required to save" do
    @list.description = nil
    assert @list.save
  end

  test "title should not be too long" do
    @list.title = 'a' * 256
    assert_not @list.valid?
  end

  test "description should not be too long" do
    @list.description = 'a' * 30_001
    assert_not @list.valid?
  end

  test "should delete" do
    if @list.save
      @list.destroy
      assert @list.destroyed?
    end
  end

  test "Should nullify created_by, when the corresponding user is deleted" do
    if @list.created_by.destroy
      @list.reload
      assert @list.created_by.nil?
    end
  end
end
