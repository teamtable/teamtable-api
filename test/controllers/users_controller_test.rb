require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = users(:alice)
    log_in_as(@user)

    @cards = [cards(:one), cards(:two), cards(:three), cards(:four)]
    @assignments = [assignments(:one), assignments(:two), assignments(:three), assignments(:four)]
  end

  test "created_cards should return the cards the user created" do
    post cards_url, params:
      { card: { title: @cards[0].title, description: @cards[0].description, list: @cards[0].list } },
         headers: { Authorization: @authorization_token }, as: :json
    @cards[0].id = JSON.parse(response.body)[:id]
    post cards_url, params:
      { card: { title: @cards[1].title, description: @cards[1].description, list: @cards[1].list } },
         headers: { Authorization: @authorization_token }, as: :json
    @cards[1].id = JSON.parse(response.body)[:id]
    post cards_url, params:
      { card: { title: @cards[2].title, description: @cards[2].description, list: @cards[2].list } },
         headers: { Authorization: @authorization_token }, as: :json
    @cards[2].id = JSON.parse(response.body)[:id]

    get user_created_cards_url(@user), headers: { Authorization: @authorization_token }, as: :json
    response_body_include?([@cards[0].id.to_s, @cards[1].id.to_s, @cards[2].id.to_s].map { |id| "\"id\":" + id })
    response_body_not_include? ["\"id\":" + @cards[3].id.to_s]

  end

  test "completed_cards should return the cards the user completed" do
    patch card_url(@cards[0].id), params: { card: { state: "done" } },
         headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    patch card_url(@cards[1].id), params: { card: { state: "done" } },
         headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    get user_completed_cards_url(@user), headers: { Authorization: @authorization_token }, as: :json
    response_body_include?([@cards[0].id.to_s, @cards[1].id.to_s].map { |id| "\"id\":" + id })
  end

  test "assigned_cards should return the cards the user is assigned to" do
    get user_assigned_cards_url(@user), headers: { Authorization: @authorization_token }, as: :json
    response_body_include?([@cards[0].id.to_s, @cards[3].id.to_s].map { |id| "\"id\":" + id })
    response_body_not_include?([@cards[1].id.to_s, @cards[2].id.to_s].map { |id| "\"id\":" + id })
  end

  test "doing_cards should return the cards the user is assigned to and marked as doing" do
    get user_doing_cards_url(@user), headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"id\":" + @cards[0].id.to_s]
    response_body_not_include?([@cards[3].id.to_s, @cards[1].id.to_s, @cards[2].id.to_s].map { |id| "\"id\":" + id })
  end
end
