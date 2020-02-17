require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  def setup
    @attachment = attachments(:one)
    @tag = tags(:one)
    @card = cards(:one)
  end

  test "should be valid" do
    assert @attachment.valid?
  end

  test "save valid attachment" do
    assert @attachment.save
  end

  test "card_id should be present" do
    @attachment.card_id = nil
    assert_not @attachment.valid?
  end

  test "tag_id should be present" do
    @attachment.tag_id = nil
    assert_not @attachment.valid?
  end

  test "card-tag combination should be unique" do
    duplicate_attachment = @attachment.dup
    @attachment.save
    assert_not duplicate_attachment.valid?
  end

  test "should delete" do
    if @attachment.save
      @attachment.destroy
      assert @attachment.destroyed?
    end
  end
end
