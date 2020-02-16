require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @users = [users(:alice), users(:bob), users(:clara)]
    log_in_as(@users[0])

    @projects = [projects(:one), projects(:two), projects(:three), projects(:four)]

    @memberships = [memberships(:one), memberships(:two), memberships(:three), memberships(:four)]
  end

  test "should get index" do
    get memberships_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "index should only return all memberships belonging to projects the user is a member of" do
    get memberships_url, headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"id\":" + @memberships[0].id.to_s, "\"id\":" + @memberships[1].id.to_s,
                            "\"id\":" + @memberships[2].id.to_s]
    response_body_not_include? ["\"id\":" + @memberships[3].id.to_s]
  end

  test "should create membership" do
    assert_difference('Membership.count', 1) do
      post memberships_url, params: { project_id: @projects[3].id, user_id: @users[1].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "should create membership when email is passed instead of id" do
    assert_difference('Membership.count', 1) do
      post memberships_url, params: { project_id: @projects[3].id, email: " " + @users[2].email.upcase + " " },
           headers: { Authorization: @authorization_token }, as: :json
      assert_response :created
    end
  end

  test "should not create membership if the current user is not member of the project" do
    assert_no_difference('Membership.count') do
      post memberships_url, params: { project_id: @projects[1].id, user_id: @users[2].id },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "should show membership if it belongs to the user" do
    # get membership_url(Membership.first), headers: { Authorization: @authorization_token }, as: :json
    get membership_url(@memberships[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "should show membership if the user is member of the project" do
    get membership_url(@memberships[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "should not show membership if the user is not member of the project" do
    get membership_url(@memberships[3]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
  end

  test "should destroy membership" do
    assert_difference('Membership.count', -1) do
      delete membership_url(@memberships[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should destroy membership if the current user created the project" do
    assert_difference('Membership.count', -1) do
      delete membership_url(@memberships[2]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should not destroy membership if neither it belongs to the user nor the user created the project" do
    assert_no_difference('Membership.count') do
      delete membership_url(@memberships[3]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end
end
