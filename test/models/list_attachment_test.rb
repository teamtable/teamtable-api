require 'test_helper'

class ListAttachmentTest < ActiveSupport::TestCase
  def setup
    @list_attachment = list_attachments(:one)
    @tag = tags(:one)
    @list = lists(:one)
  end

  test "should be valid" do
    assert @list_attachment.valid?
  end

  test "save valid list_attachments[0]" do
    assert @list_attachment.save
  end

  test "list_id should be present" do
    @list_attachment.list_id = nil
    assert_not @list_attachment.valid?
  end

  test "tag_id should be present" do
    @list_attachment.tag_id = nil
    assert_not @list_attachment.valid?
  end

  test "list-tag combination should be unique" do
    duplicate_list_attachment = @list_attachment.dup
    @list_attachment.save
    assert_not duplicate_list_attachment.valid?
  end

  test "should delete" do
    if @list_attachment.save
      @list_attachment.destroy
      assert @list_attachment.destroyed?
    end
  end

  test "should be destroyed if the associated list is destroyed" do
    @list_attachment.list.destroy && assert_raise(ActiveRecord::RecordNotFound) { @list_attachment.reload }
  end

  test "should be destroyed if the associated tag is destroyed" do
    @list_attachment.tag.destroy && assert_raise(ActiveRecord::RecordNotFound) { @list_attachment.reload }
  end
end
