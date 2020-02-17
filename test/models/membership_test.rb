require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  def setup
    @membership = memberships(:one)
    @user = users(:alice)
    @project = projects(:one)
  end

  test "should be valid" do
    assert @membership.valid?
  end

  test "save valid memberships" do
    assert @membership.save
  end

  test "project_id should be present" do
    @membership.project_id = nil
    assert_not @membership.valid?
  end

  test "user_id should be present" do
    @membership.user_id = nil
    assert_not @membership.valid?
  end

  test "project-user combination should be unique" do
    duplicate_membership = @membership.dup
    @membership.save
    assert_not duplicate_membership.valid?
  end

  test "should delete" do
    if @membership.save
      @membership.destroy
      assert @membership.destroyed?
    end
  end

  test "should be destroyed if the associated project is destroyed" do
    assert_raise(ActiveRecord::RecordNotFound) { @membership.reload } if @membership.project.destroy
  end

  test "should be destroyed if the associated user is destroyed" do
    assert_raise(ActiveRecord::RecordNotFound) { @membership.reload } if @membership.user.destroy
  end
end
