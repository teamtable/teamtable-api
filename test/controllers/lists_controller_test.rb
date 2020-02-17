require 'test_helper'

class ListsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:alice), users(:bob), users(:clara)]
    log_in_as(@users[0])

    @projects = [projects(:one)]
    @lists = [lists(:one), lists(:two), lists(:three), lists(:four), lists(:five), lists(:six)]
    @tags = [tags(:one), tags(:two), tags(:three), tags(:four)]
    @cards = [cards(:one), cards(:two), cards(:three), cards(:four)]
    @list_positions = [list_positions(:one), list_positions(:two), list_positions(:three), list_positions(:six),
                       list_positions(:seven)]

    @users[0].update(current_project_id: @projects[0].id)
  end

  test "should get index" do
    get lists_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "index should only include the lists of the users current project" do
    get lists_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@lists[0].id.to_s + ",\"title\":\"Planning\"",
                            @lists[3].id.to_s + ",\"title\":\"Development\""]
    response_body_not_include? [@lists[1].id.to_s + ",\"title\":\"Conception\"",
                                @lists[2].id.to_s + ",\"title\":\"Janis\"",
                                @lists[5].id.to_s + ",\"title\":\"A list alice has access to.\""]
  end

  test "the lists returned by index should include their position for the current user" do
    get lists_url, headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"position\":0", "\"position\":1", "\"position\":2"]
  end

  test "should show list, including its position" do
    get list_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"id\":" + @lists[0].id.to_s, @lists[0].title, @lists[0].description, "\"position\":0"]
  end

  test "correct response, when record is not found" do
    get list_url(5), headers: { Authorization: @authorization_token }, as: :json
    assert_response :not_found
    response_body_include? ["Couldn't find List with 'id'=5"]
  end

  test "should create list" do
    assert_difference('List.count', 1) do
      post lists_url, params:
        { list: { title: @lists[0].title, description: @lists[0].description, project_id: @lists[0].project_id } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "create should return the list including its position" do
    post lists_url, params:
      { list: { title: @lists[0].title, description: @lists[0].description, project_id: @lists[0].project_id } },
         headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"id\":" + List.last.id.to_s, @lists[0].title, @lists[0].description, "\"position\":3"]
  end

  test "should create list_positions for each project member and include the current users list_position" do
    assert_difference('ListPosition.count', @lists[0].project.users.length) do
      post lists_url, params:
        { list: { title: @lists[0].title, description: @lists[0].description, project_id: @lists[0].project_id } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    response_body_include? ["\"position\":" + (@lists[0].project.lists.length - 1).to_s]
  end

  test "should save created_by" do
    post lists_url, params:
      { list: { title: @lists[0].title, description: @lists[0].description, project_id: @lists[0].project_id } },
         headers: { Authorization: @authorization_token }, as: :json
    assert List.last.created_by_id == @users[0].id
  end

  test "Should not create list if record is invalid" do
    assert_no_difference('List.count') do
      post lists_url, params: { list: { title: "", description: @lists[0].description } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unprocessable_entity

    assert_no_difference('List.count') do
      assert_raise(NoMethodError) do
        post lists_url, params: { list: "abc" },
             headers: { Authorization: @authorization_token }, as: :json
      end
    end
  end

  test "should update list" do
    new_description = "new description"
    new_title = "new title"
    patch list_url(@lists[0]), params: { list: { title: new_title, description: new_description } },
          headers: { Authorization: @authorization_token }, as: :json
    # assert_response :ok # save lines, because of code metrics
    assert new_title == List.find(@lists[0].id).title
    assert new_description == List.find(@lists[0].id).description
  end

  test "should destroy list" do
    assert_difference('List.count', -1) do
      delete list_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should not destroy list if the current user is not member of its project" do
    assert_no_difference('List.count') do
      delete list_url(@lists[1]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "destroy (only) should move down lists with higher positions of the project" do
    delete list_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    @list_positions[1].reload
    @list_positions[2].reload
    assert_equal @list_positions[1].position, 0
    assert_equal @list_positions[2].position, 1

    @list_positions[3].reload
    @list_positions[4].reload
    assert_equal @list_positions[3].position, 1
    assert_equal @list_positions[4].position, 0
  end

  test "destroy should (only) return the updated list_positions" do
    delete list_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    @list_positions[1].reload
    @list_positions[2].reload
    @list_positions[3].reload
    @list_positions[4].reload

    response_body_include?(
      ["\"id\":" + @list_positions[1].id.to_s, "\"user_id\":" + @list_positions[1].user_id.to_s + ",\"position\":0",
       "\"id\":" + @list_positions[2].id.to_s, "\"user_id\":" + @list_positions[2].user_id.to_s + ",\"position\":1",
       "\"id\":" + @list_positions[3].id.to_s, "\"user_id\":" + @list_positions[3].user_id.to_s + ",\"position\":1"]
    )
    response_body_not_include?(
      ["\"id\":" + @list_positions[4].id.to_s, "\"user_id\":" + @list_positions[4].user_id.to_s + ",\"position\":0"]
    )
  end

  test "should show members" do
    get list_members_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    # assert_response :ok # save lines, because of code metrics
    response_body_include? [@users[0].email, @users[1].email]
    response_body_not_include? [@users[2].email]
  end

  test "should not show members if the current user is not member of the lists project" do
    get list_members_url(@lists[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should show cards" do
    get list_cards_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include?([@cards[0].id.to_s, @cards[1].id.to_s].map { |id| "\"id\":" + id })
    response_body_not_include?([@cards[2].id.to_s, @cards[3].id.to_s].map { |id| "\"id\":" + id })
  end

  test "should not show cards if the current user is not member of the lists project" do
    get list_cards_url(@lists[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should show tags" do
    get list_tags_url(@lists[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include?([@tags[0].id.to_s, @tags[3].id.to_s].map { |id| "\"id\":" + id })
    response_body_not_include?([@tags[1].id.to_s, @tags[2].id.to_s].map { |id| "\"id\":" + id })
  end

  test "should not show tags if the current user is not member of the lists project" do
    get list_tags_url(@lists[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should update list_position" do
    params = { position: 0 }
    patch list_update_position_url(@lists[0]),
          params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @lists[0].reload
    assert_equal params[:position], @lists[0].list_positions.find_by(user_id: @users[0].id).position
  end
end
