require 'test_helper'

class ListPositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    log_in_as(@user)

    @lists = [lists(:one), lists(:two), lists(:three), lists(:four), lists(:five)]

    @list_positions = [list_positions(:one), list_positions(:two), list_positions(:three), list_positions(:four),
                       list_positions(:five), list_positions(:six), list_positions(:seven), list_positions(:eight)]
  end

  test "should update list_positions" do
    params = { list_positions: [
      { list_id: @lists[4].id, position: 1 },
      { list_id: @lists[3].id, position: 2 }
    ] }
    patch list_positions_update_all_url, params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @list_positions[1].reload
    @list_positions[2].reload
    assert_equal params[:list_positions].first[:position], @list_positions[2].position
    assert_equal params[:list_positions].last[:position], @list_positions[1].position
  end

  test "status should be unprocessable_entity if params are invalid" do
    params = {
      list_id: @lists[4].id, position: 1,
      list_position: { list_id: @lists[3].id, position: 2 }
    }
    patch list_positions_update_all_url, params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :unprocessable_entity
  end

  test "ListPositions should be deleted, when the the user is deleted" do
    assert_difference('ListPosition.count', -4) do
      @user.destroy
    end
  end

  test "ListPositions should be deleted, when the the list is deleted" do
    assert_difference('ListPosition.count', -2) do
      @lists[0].destroy
    end
  end
end
