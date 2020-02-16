require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:alice), users(:bob), users(:clara)]

    log_in_as(@users[0])
    @project = projects(:one)
    @tags = [tags(:one), tags(:two), tags(:three), tags(:four)]
    @cards = [cards(:one), cards(:two), cards(:three), cards(:four)]
  end

  test "should show tag" do
    get tag_url(@tags[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@tags[0].id.to_s, @tags[0].name, @tags[0].color]
  end

  test "correct response, when record is not found" do
    get tag_url(5), headers: { Authorization: @authorization_token }, as: :json
    assert_response :not_found
    response_body_include? ["Couldn't find Tag with 'id'=5"]
  end

  test "should create tag" do
    assert_difference('Tag.count', 1) do
      post tags_url, params: { tag: { name: "new tag", color: @tags[0].color, project_id: @project.id } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "Should not create tag if record is invalid" do
    assert_no_difference('Tag.count') do
      post tags_url, params: { tag: { name: "", color: @tags[0].color } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unprocessable_entity

    assert_no_difference('Tag.count') do
      assert_raise(NoMethodError) do
        post tags_url, params: { tag: "abc" },
             headers: { Authorization: @authorization_token }, as: :json
      end
    end
  end

  test "should update tag" do
    new_color = "#BBB"
    new_name = "new name"
    patch tag_url(@tags[0]), params: { tag: { name: new_name, color: new_color } },
          headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    assert new_name == Tag.find(@tags[0].id).name
    assert new_color == Tag.find(@tags[0].id).color
  end

  test "should destroy tag" do
    assert_difference('Tag.count', -1) do
      delete tag_url(@tags[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should show cards" do
    get tag_cards_url(@tags[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? ["\"id\":" + @cards[0].id.to_s, "\"id\":" + @cards[1].id.to_s]
    response_body_not_include? ["\"id\":" + @cards[2].id.to_s]
  end

  test "should not show cards if the current user is not member of the tags project" do
    get tag_cards_url(@tags[3]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end
end
