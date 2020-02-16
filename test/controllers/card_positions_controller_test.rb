require 'test_helper'

class CardPositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    log_in_as(@user)

    @cards = [cards(:one), cards(:two), cards(:three), cards(:four), cards(:five)]
    @card_positions = [card_positions(:one), card_positions(:two), card_positions(:three), card_positions(:four),
                       card_positions(:five), card_positions(:six), card_positions(:seven)]
    @lists = [lists(:one), lists(:two), lists(:three), lists(:four), lists(:five)]
  end

  test "should update card_positions" do
    params = { card_positions: [
      { card_id: @cards[0].id, position: 1 },
      { card_id: @cards[1].id, position: 0 }
    ] }
    patch card_positions_update_all_url, params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @card_positions[0].reload
    @card_positions[1].reload
    assert_equal params[:card_positions].first[:position], @card_positions[0].position
    assert_equal params[:card_positions].last[:position], @card_positions[1].position
  end

  test "should update card_positions and the referenced list, if card: [:id, :list_id] param is present" do
    params = { card: { id: @cards[0].id, list_id: @lists[3].id },
               card_positions: [{ card_id: @cards[0].id, position: 1 }, { card_id: @cards[1].id, position: 0 }] }
    patch card_positions_update_all_url, params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :ok
    @card_positions[0].reload
    @card_positions[1].reload
    assert_equal params[:card_positions].first[:position], @card_positions[0].position
    assert_equal params[:card_positions].last[:position], @card_positions[1].position

    @cards[0].reload
    assert_equal @lists[3].id, @cards[0].list_id
    response_body_include? [@cards[0].to_json]
  end

  test "status should be unprocessable_entity if params are invalid" do
    params = {
      card_id: @cards[4].id, position: 1,
      card_position: { card_id: @cards[3].id, position: 2 }
    }
    patch card_positions_update_all_url, params: params, headers: { Authorization: @authorization_token }, as: :json
    assert_response :unprocessable_entity
  end

  test "CardPositions should be deleted, when the the user is deleted" do
    assert_difference('CardPosition.count', -2) do
      @user.destroy
    end
  end

  test "CardPositions should be deleted, when the the card is deleted" do
    assert_difference('CardPosition.count', -2) do
      @cards[0].destroy
    end
  end
end
