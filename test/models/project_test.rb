require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = projects(:one)
  end

  test "should be valid" do
    assert @project.valid?
  end

  test "save valid project" do
    assert @project.save
  end

  test "title should be present" do
    @project.title = "     "
    assert_not @project.valid?
  end

  test "created_by should be present" do
    @project.created_by = nil
    assert_not @project.valid?
  end

  test "description should not be required to save" do
    @project.description = nil
    assert @project.save
  end

  test "title should not be too long" do
    @project.title = 'a' * 256
    assert_not @project.valid?
  end

  test "description should not be too long" do
    @project.description = 'a' * 30_001
    assert_not @project.valid?
  end

  test "should delete" do
    if @project.save
      @project.destroy
      assert @project.destroyed?
    end
  end

  test "should nullify created_by, when the corresponding user is deleted" do
    if @project.created_by.destroy
      @project.reload
      assert @project.created_by.nil?
    end
  end

  test "should update current_project of created_by" do
    assert @project.save
    assert @project.created_by.current_project_id == @project.id
  end

end
