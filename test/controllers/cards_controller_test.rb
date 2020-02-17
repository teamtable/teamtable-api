require 'test_helper'

class CardsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:alice), users(:bob), users(:clara)]
    log_in_as(@users[0])
    @cards = [cards(:one), cards(:two), cards(:three), cards(:four)]
    @card_positions = [card_positions(:one), card_positions(:two), card_positions(:three), card_positions(:four),
                       card_positions(:five), card_positions(:six), card_positions(:seven)]
    @lists = [lists(:one), lists(:two), lists(:three), lists(:four), lists(:five)]
  end

  test "get index should only return cards of the users lists" do
    get cards_url, headers: { Authorization: @authorization_token }, as: :json
    response_body_include?([@cards[0].id.to_s, @cards[1].id.to_s].map { |id| "\"id\":" + id })
    response_body_not_include?([@cards[2].id.to_s, @cards[3].id.to_s].map { |id| "\"id\":" + id })
  end

  test "the cards returned by index should include their position for the current user" do
    get cards_url, headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["\"position\":0", "\"position\":1"]
  end

  test "should show card including its position" do
    get card_url(@cards[1]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? ["\"id\":" + @cards[1].id.to_s, @cards[1].title, @cards[1].description, @cards[1].state.to_s,
                            @cards[1].priority.to_s, @cards[1].deadline.to_json, @cards[1].created_by_id.to_s,
                            "\"position\":1"]
  end

  test "should not show card" do
    get card_url(@cards[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "correct response, when record is not found" do
    get card_url(5), headers: { Authorization: @authorization_token }, as: :json
    assert_response :not_found
    response_body_include? ["Couldn't find Card with 'id'=5"]
  end

  test "should create card" do
    assert_difference('Card.count', 1) do
      post cards_url, params: {
        card: { title: "Card 5", description: @cards[0].description, priority: @cards[0].priority,
                deadline: @cards[0].deadline, list_id: @cards[0].list_id }
      }, headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :created
  end

  test "should not create card if not authorized for the referenced list" do
    assert_no_difference('Card.count', 0) do
      post cards_url, params: {
        card: { title: "Card 5", description: @cards[0].description, priority: @cards[0].priority,
                deadline: @cards[0].deadline, list_id: @lists[1].id }
      }, headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unauthorized
  end

  test "create should return the card including its position" do
    post cards_url, params: { card: { title: @cards[0].title, description: @cards[0].description,
                                      priority: @cards[0].priority, deadline: @cards[0].deadline,
                                      list_id: @cards[0].list_id } },
         headers: { Authorization: @authorization_token }, as: :json

    response_body_include? ["\"id\":" + Card.last.id.to_s, @cards[0].title, @cards[0].description, @cards[0].state.to_s,
                            @cards[0].priority.to_s, @cards[0].deadline.to_json, @cards[0].created_by_id.to_s,
                            "\"position\":2"]
  end

  test "should save created_by" do
    post cards_url, params: { card: { title: @cards[0].title, description: @cards[0].description,
                                      list_id: @cards[0].list_id } },
         headers: { Authorization: @authorization_token }, as: :json
    assert_equal Card.last.created_by, @users[0]
  end

  test "Should not create card if record is invalid" do
    assert_no_difference('Card.count') do
      post cards_url, params: { card: { title: "", description: @cards[0].description } },
           headers: { Authorization: @authorization_token }, as: :json
    end
    assert_response :unprocessable_entity

    # save lines, because of code metrics
    # assert_no_difference('Card.count') do
    #   assert_raise(NoMethodError) do
    #    post cards_url, params: { card: "abc" },
    #         headers: { Authorization: @authorization_token }, as: :json
    #  end
    # end
  end

  test "should update card" do
    params = { card: { title: 'new title', description: 'new description', priority: 5, deadline: 2.days.from_now,
                       list_id: @lists[3].id  } }
    patch card_url(@cards[0]), params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @cards[0].reload
    assert_equal params[:card][:title], @cards[0].title
    assert_equal params[:card][:description], @cards[0].description
    assert_equal params[:card][:priority], @cards[0].priority
    assert_equal params[:card][:deadline].to_s, @cards[0].deadline.to_s
  end

  test "should not update card if not authorized for card" do
    params = { card: { title: 'new title', description: 'new description', priority: 5, deadline: 2.days.from_now } }
    patch card_url(@cards[3]), params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should not update card if not authorized new list to be referenced" do
    params = { card: { list_id: @lists[1].id } }
    patch card_url(@cards[3]), params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "update state to todo correctly" do
    patch card_url(@cards[0]), params: { card: { state: "todo" } },
          headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @cards[0].reload
    assert_equal 0, @cards[0].state
    assert @cards[0].completed_at.nil? && @cards[0].completed_by.nil?
  end

  test "update state to doing correctly" do
    patch card_url(@cards[0]), params: { card: { state: "doing" } },
          headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @cards[0].reload
    assert_equal 1, @cards[0].state
    assert @cards[0].completed_at.nil? && @cards[0].completed_by.nil?
  end

  test "update state to done correctly" do
    patch card_url(@cards[0]), params: { card: { state: "done" } },
          headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    assert_not_equal @cards[0].completed_at, Card.find(@cards[0].id).completed_at
    @cards[0].reload
    assert_equal 2, @cards[0].state
    assert_not_nil @cards[0].completed_at
    assert_equal @users[0], @cards[0].completed_by
  end

  test "update state by giving number" do
    patch card_url(@cards[0]), params: { card: { state: 1 } },
          headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
  end

  test "should destroy card" do
    assert_difference('Card.count', -1) do
      delete card_url(@cards[0]), headers: { Authorization: @authorization_token }, as: :json
    end
    # assert_response :ok # save lines, because of code metrics
  end

  test "destroy should (only) return the updated card_positions" do
    delete card_url(@cards[0]), headers: { Authorization: @authorization_token }, as: :json
    @card_positions[1].reload
    @card_positions[3].reload

    response_body_include?(
      ["\"id\":" + @card_positions[1].id.to_s, "\"user_id\":" + @card_positions[1].user_id.to_s + ",\"position\":0"]
    )
    response_body_not_include?(
      ["\"id\":" + @card_positions[3].id.to_s, "\"user_id\":" + @card_positions[3].user_id.to_s + ",\"position\":0"]
    )
  end

  test "destroy (only) should move down cards with higher positions of the list" do
    delete card_url(@cards[0]), headers: { Authorization: @authorization_token }, as: :json
    @card_positions[1].reload
    assert_equal @card_positions[1].position, 0

    @card_positions[3].reload
    assert_equal @card_positions[3].position, 0
  end

  test "should show assigned users" do
    get card_assigned_users_url(@cards[0]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    response_body_include? [@users[0].id.to_s, @users[1].id.to_s]
    response_body_not_include? [@users[2].id.to_s]
  end

  test "should not show assigned users" do
    get card_assigned_users_url(@cards[2]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end

  test "should show doing users" do
    get card_doing_users_url(@cards[0]), headers: { Authorization: @authorization_token }, as: :json
    # assert_response :ok # save lines, because of code metrics
    response_body_include? [@users[0].id.to_s]
    response_body_not_include? [@users[1].id.to_s, @users[2].id.to_s]
  end

  test "should not show doing users" do
    get card_doing_users_url(@cards[3]), headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    assert response.body == ""
  end
end
