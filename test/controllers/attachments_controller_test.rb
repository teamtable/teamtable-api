require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    log_in_as(@user)

    @cards = [cards(:one), cards(:two), cards(:three), cards(:four)]
    @tags = [tags(:one), tags(:two), tags(:three), tags(:four), tags(:five)]
    @attachments = [attachments(:one), attachments(:two), attachments(:three), attachments(:four)]
  end

  test "should create attachment" do
    assert_difference('Attachment.count', 1) do
      post attachments_url, params: { card_id: @cards[0].id, tag_id: @tags[1].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "should not create attachment if unauthorized" do
    assert_no_difference 'Attachment.count' do
      post attachments_url, params: { card_id: @cards[2].id, tag_id: @tags[4].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "attaching a tag to a card should add the card to the tags cards" do
    assert_difference('Tag.find(@tags[1].id).cards.count', 1) do
      post attachments_url, params: { card_id: @cards[0].id, tag_id: @tags[1].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
  end

  test "should destroy attachment" do
    assert_difference('Attachment.count', -1) do
      delete attachment_url(@attachments[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should not destroy attachment if not authorized" do
    assert_no_difference 'Attachment.count' do
      delete attachment_url(@attachments[3]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "Attachments should be deleted, when the the tag is deleted" do
    assert_difference('Attachment.count', -2) do
      @tags[0].destroy
    end
  end

  test "Attachments should be deleted, when the the card is deleted" do
    assert_difference('Attachment.count', -2) do
      @cards[0].destroy
    end
  end
end
