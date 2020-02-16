require 'test_helper'

class CardTest < ActiveSupport::TestCase
  def setup
    @card = cards(:one)
    @users = [users(:alice), users(:bob), users(:clara)]
  end

  test "should be valid" do
    assert @card.valid?
  end

  test "save valid card" do
    assert @card.save
  end

  test "should create card_positions for each of the projects users, when creating a card" do
    assert_equal @card.card_positions.length, 2
    assert @card.card_positions.find_by(user_id: @users[0].id)
    assert @card.card_positions.find_by(user_id: @users[1].id)
    assert_not @card.card_positions.find_by(user_id: @users[2].id)
  end

  test "title should be present" do
    @card.title = "     "
    assert_not @card.valid?
  end

  test "title should not be too long" do
    @card.title = 'a' * 256
    assert_not @card.valid?
  end

  test "description should not be required to save" do
    @card.description = nil
    assert @card.save
  end

  test "description should not be too long" do
    @card.description = 'a' * 30_001
    assert_not @card.valid?
  end

  test "state validation should accept valid numbers" do
    3.times do |i|
      @card.state = i
      assert @card.valid?, "#{i} should be a valid state"
    end
  end

  test "state validation should reject invalid numbers" do
    invalid_states = %w[-1 3 10]
    invalid_states.each do |invalid_state|
      @card.state = invalid_state
      assert_not @card.valid?, "#{invalid_state.inspect} should be invalid"
    end
  end

  test "priority validation should accept valid numbers" do
    10.times do |i|
      @card.priority = i
      assert @card.valid?, "#{i} should be a valid priority"
    end
  end

  test "priority validation should reject invalid numbers" do
    invalid_priorities = %w[-1 11 11 99]
    invalid_priorities.each do |invalid_priority|
      @card.priority = invalid_priority
      assert_not @card.valid?, "#{invalid_priority.inspect} should be invalid"
    end
  end

  test "created_by should be present" do
    @card.created_by = nil
    assert_not @card.valid?
  end

  test "should delete" do
    if @card.save
      @card.destroy
      assert @card.destroyed?
    end
  end

  test "should nullify created_by, when the corresponding user is deleted" do
    if @card.created_by.destroy
      @card.reload
      assert @card.created_by.nil?
    end
  end

  test "completed_by should be accepted" do
    @card.completed_by = @users[0]
    assert @card.valid?
    assert @card.save
  end

  test "should nullify completed_by, when the corresponding user is deleted" do
    @card.update(state: 2, completed_by_id: @users[0].id, completed_at: Time.zone.now)
    @users[0].destroy
    @card.reload
    assert_nil @card.completed_by
  end
end
