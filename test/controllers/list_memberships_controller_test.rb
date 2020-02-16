require 'test_helper'

class ListListMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @users = [users(:alice), users(:bob), users(:clara)]
    log_in_as(@users[0])

    @lists = [lists(:one), lists(:two), lists(:three), lists(:four)]
    @list_memberships = [list_memberships(:one), list_memberships(:two), list_memberships(:three),
                         list_memberships(:four)]
  end

  test "should get index" do
    get list_memberships_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "index should only return all list_memberships belonging to lists the user is a member of" do
    get list_memberships_url, headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"id\":" + @list_memberships[0].id.to_s, "\"id\":" + @list_memberships[1].id.to_s,
                            "\"id\":" + @list_memberships[2].id.to_s]
    response_body_not_include? ["\"id\":" + @list_memberships[3].id.to_s]
  end

  test "should create list_membership" do
    assert_difference('ListMembership.count', 1) do
      post list_memberships_url, params: { list_id: @lists[3].id, user_id: @users[1].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "should create list_membership when email is passed instead of id" do
    assert_difference('ListMembership.count', 1) do
      post list_memberships_url, params: { list_id: @lists[3].id, email: " " + @users[2].email.upcase + " " },
           headers: { Authorization: @authorization_token }, as: :json
      assert_response :created
    end
  end

  test "should not create list_membership if the current user is not member of the list" do
    assert_no_difference('ListMembership.count') do
      post list_memberships_url, params: { list_id: @lists[1].id, user_id: @users[2].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "should show list_membership if it belongs to the user" do
    # get list_membership_url(ListMembership.first), headers: { Authorization: @authorization_token }, as: :json
    get list_membership_url(@list_memberships[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "should show list_membership if the user is member of the list" do
    get list_membership_url(@list_memberships[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "should not show list_membership if the user is not member of the list" do
    get list_membership_url(@list_memberships[3]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
  end

  test "should destroy list_membership" do
    assert_difference('ListMembership.count', -1) do
      delete list_membership_url(@list_memberships[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should destroy list_membership if the current user created the list" do
    assert_difference('ListMembership.count', -1) do
      delete list_membership_url(@list_memberships[2]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should not destroy list_membership if neither it belongs to the user nor the user created the list" do
    assert_no_difference('ListMembership.count') do
      delete list_membership_url(@list_memberships[3]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end
end
