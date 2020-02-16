require 'test_helper'

class ListMembershipTest < ActiveSupport::TestCase
  def setup
    @list_membership = list_memberships(:one)
    @user = users(:alice)
    @list = lists(:one)
  end

  test "should be valid" do
    assert @list_membership.valid?
  end

  test "save valid list_memberships" do
    assert @list_membership.save
  end

  test "list_id should be present" do
    @list_membership.list_id = nil
    assert_not @list_membership.valid?
  end

  test "user_id should be present" do
    @list_membership.user_id = nil
    assert_not @list_membership.valid?
  end

  test "list-user combination should be unique" do
    duplicate_list_membership = @list_membership.dup
    @list_membership.save
    assert_not duplicate_list_membership.valid?
  end

  test "should delete" do
    if @list_membership.save
      @list_membership.destroy
      assert @list_membership.destroyed?
    end
  end

  test "should be destroyed if the associated list is destroyed" do
    @list_membership.list.destroy && assert_raise(ActiveRecord::RecordNotFound) { @list_membership.reload }
  end

  test "should be destroyed if the associated user is destroyed" do
    @list_membership.user.destroy && assert_raise(ActiveRecord::RecordNotFound) { @list_membership.reload }
  end

end
