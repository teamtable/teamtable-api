require 'test_helper'

class CardPositionTest < ActiveSupport::TestCase
  def setup
    @card_positions = [card_positions(:one), card_positions(:two), card_positions(:three), card_positions(:four)]
    @card = cards(:one)
    @user = users(:alice)
  end

  test "should be valid" do
    assert @card_positions[0].valid?
  end

  test "save valid card_position" do
    assert @card_positions[0].save
  end

  test "user_id should be present" do
    @card_positions[0].user_id = nil
    assert_not @card_positions[0].valid?
  end

  test "card_id should be present" do
    @card_positions[0].card_id = nil
    assert_not @card_positions[0].valid?
  end

  test "position should be present" do
    @card_positions[0].card_id = nil
    assert_not @card_positions[0].valid?
  end

  test "card user combination should be unique" do
    duplicate_card_position = @card_positions[0].dup
    duplicate_card_position.position = 5
    @card_positions[0].save
    assert_not duplicate_card_position.valid?

    assert_raise(ActiveRecord::RecordInvalid) do
      CardPosition.create!(
        card_id: duplicate_card_position.card_id,
        user_id: duplicate_card_position.user_id,
        position: duplicate_card_position.position
      )
    end
  end

  test "user position combination should be unique" do
    duplicate_card_position = @card_positions[0].dup
    duplicate_card_position.card_id = @card_positions[1].card_id
    @card_positions[0].save
    assert_not duplicate_card_position.valid?

    assert_raise(ActiveRecord::RecordInvalid) do
      CardPosition.create!(
        card_id: duplicate_card_position.card_id,
        user_id: duplicate_card_position.user_id,
        position: duplicate_card_position.position
      )
    end
  end

  test "should delete" do
    if @card_positions[0].save
      @card_positions[0].destroy
      assert @card_positions[0].destroyed?
    end
  end

  test "should be destroyed if the associated card is destroyed" do
    @card_positions[0].card.destroy && assert_raise(ActiveRecord::RecordNotFound) { @card_positions[0].reload }
  end

  test "should be destroyed if the associated user is destroyed" do
    @card_positions[0].user.destroy && assert_raise(ActiveRecord::RecordNotFound) { @card_positions[0].reload }
  end
end
