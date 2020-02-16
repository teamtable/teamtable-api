require 'test_helper'

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    log_in_as(@user)

    @cards = [cards(:one), cards(:two), cards(:three), cards(:four)]

    @assignments = [assignments(:one), assignments(:two), assignments(:three), assignments(:three)]
  end

  test "should create assignment" do
    assert_difference('Assignment.count', 1) do
      post assignments_url, params: { card_id: @cards[1].id, user_id: @user.id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "should not create assignment" do
    assert_no_difference('Assignment.count') do
      post assignments_url, params: { card_id: @cards[2].id, user_id: @user.id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "should create assignment with doing set to true" do
    assert_difference('Assignment.count', 1) do
      post assignments_url, params: { card_id: @cards[1].id, user_id: @user.id, doing: true },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
    response_body_include? ["\"doing\":true"]
  end

  test "should update assignment" do
    params = { doing: true }
    patch assignment_url(@assignments[0]), params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @assignments[0].reload
    assert_equal params[:doing], @assignments[0].doing
  end

  test "assigning a user to a card should add the card to the users cards" do
    assert_difference('User.find(@user.id).cards.count', 1) do
      post assignments_url, params: { card_id: @cards[1].id, user_id: @user.id },
           headers: { Authorization: @authorization_token }, as: :json
    end
  end

  test "should destroy assignment" do
    assert_difference('Assignment.count', -1) do
      delete assignment_url(@assignments[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should not destroy assignment if the card does not belong to the users projects" do
    delete assignment_url(@assignments[1]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "Assignments should be deleted, when the the user is deleted" do
    assert_difference('Assignment.count', -2) do
      @user.destroy
    end
  end

  test "Assignments should be deleted, when the the card is deleted" do
    assert_difference('Assignment.count', -2) do
      @cards[0].destroy
    end
  end
end
