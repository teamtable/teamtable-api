require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:alice), users(:bob), users(:clara)]
    log_in_as(@users[0])

    @projects = [projects(:one), projects(:two), projects(:three), projects(:four)]
    @tags = [tags(:one), tags(:two), tags(:three), tags(:four)]
    @lists = [lists(:one), lists(:two), lists(:three), lists(:four)]
    @cards = [cards(:one), cards(:two), cards(:three), cards(:four), cards(:five)]
    @card_positions = [card_positions(:one), card_positions(:two), card_positions(:three), card_positions(:four),
                       card_positions(:five), card_positions(:six), card_positions(:seven)]
  end

  test "should get index" do
    get projects_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "index should only include the current users projects" do
    get projects_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@projects[0].id.to_s, @projects[3].id.to_s]
    response_body_not_include? [@projects[1].id.to_s, @projects[2].id.to_s]
  end

  test "should show project" do
    get project_url(@projects[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@projects[0].id.to_s, @projects[0].title, @projects[0].description]
  end

  test "should get current project, also if user has not created it himself" do
    get current_project_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? ["\"id\":" + @projects[3].id.to_s]
  end

  test "should update current project after create" do
    post projects_url, params: { project: { title: "bla", description: @projects[0].description } },
         headers: { Authorization: @authorization_token }, as: :json
    @users[0].reload
    get current_project_url, headers: { Authorization: @authorization_token }, as: :json
    assert @users[0].current_project_id == Project.last.id
    assert_response :ok
    response_body_include? ["\"id\":" + Project.last.id.to_s]
  end

  test "should update current project after show" do
    get project_url(@projects[3]), headers: { Authorization: @authorization_token }, as: :json
    @users[0].reload
    get current_project_url, headers: { Authorization: @authorization_token }, as: :json
    assert @users[0].current_project_id == @projects[3].id
    assert_response :ok
    response_body_include? ["\"id\":" + @projects[3].id.to_s]
  end

  test "should respond with error, if user is not member of a project" do
    log_in_as(@users[2])
    get current_project_url, headers: { Authorization: @authorization_token }, as: :json
    assert_response :not_found
    response_body_include? ["\"error\":\"User is not member of a project.\""]
  end

  test "correct response, when record is not found" do
    get project_url(5), headers: { Authorization: @authorization_token }, as: :json
    assert_response :not_found
    response_body_include? ["Couldn't find Project with 'id'=5"]
  end

  test "should create project" do
    assert_difference('Project.count', 1) do
      post projects_url, params: { project: { title: @projects[0].title, description: @projects[0].description } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "should create membership when creating a project" do
    post projects_url, params: { project: { title: @projects[0].title, description: @projects[0].description } },
         headers: { Authorization: @authorization_token }, as: :json
    assert Project.last.users.first == @users[0]
  end

  test "should save created_by" do
    post projects_url, params: { project: { title: @projects[0].title, description: @projects[0].description } },
         headers: { Authorization: @authorization_token }, as: :json

    assert Project.last.created_by_id == @users[0].id
  end

  test "Should not create project if record is invalid" do
    assert_no_difference('Project.count') do
      post projects_url, params: { project: { title: "", description: @projects[0].description } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unprocessable_entity

    assert_no_difference('Project.count') do
      assert_raise(NoMethodError) do
        post projects_url, params: { project: "abc" },
             headers: { Authorization: @authorization_token }, as: :json
      end
    end
  end

  test "should update project" do
    new_description = "new description"
    new_title = "new title"
    patch project_url(@projects[0]), params: { project: { title: new_title, description: new_description } },
          headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    assert new_title == Project.find(@projects[0].id).title
    assert new_description == Project.find(@projects[0].id).description
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete project_url(@projects[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :ok
  end

  test "should show members" do
    get project_members_url(@projects[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@users[0].email, @users[1].email]
    response_body_not_include? [@users[2].email]
  end

  test "should not show members if the current user is not member of the project" do
    get project_members_url(@projects[1]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should show lists including cards with positions." do
    get project_lists_url(@projects[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@lists[0].id.to_s + ",\"title\":\"Planning\"",
                            "\"id\":" + @cards[0].id.to_s + ",\"title\":\"Card one\"", "\"position\":0",
                            "\"id\":" + @cards[1].id.to_s + ",\"title\":\"Card two\"", "\"position\":1",
                            @lists[3].id.to_s + ",\"title\":\"Development\""]
    response_body_not_include? [@lists[1].id.to_s + ",\"title\":\"Conception\"",
                                @lists[2].id.to_s + ",\"title\":\"Janis\""]
  end

  test "should not show lists if the current user is not member of the projects project" do
    get project_lists_url(@lists[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should show tags" do
    get project_tags_url(@projects[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@tags[0].id.to_s, @tags[1].id.to_s, @tags[2].id.to_s]
    response_body_not_include? [@tags[3].id.to_s]
  end

  test "should not show tags if the current user is not member of the project" do
    get project_tags_url(@projects[1]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end
end
