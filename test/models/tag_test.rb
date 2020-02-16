require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    # @tags = [tags(:one), tags(:two), tags(:three), tags(:four)]
    @tag = tags(:one)
  end

  test "should be valid" do
    assert @tag.valid?
  end

  test "save valid tag" do
    assert @tag.save
  end

  test "name should be present" do
    @tag.name = "     "
    assert_not @tag.valid?
  end

  test "name should not be too long" do
    @tag.name = 'a' * 24
    assert_not @tag.valid?
  end

  test "project-name combination should be unique" do
    duplicate_tag = @tag.dup
    duplicate_tag.name = @tag.name.upcase
    duplicate_tag.color = '#BBB'
    @tag.save
    assert_not duplicate_tag.valid?
  end

  test "color should be present" do
    @tag.color = "     "
    assert_not @tag.valid?
  end

  test "color validation should accept valid hexcodes" do
    valid_hexcodes = %w[#000 #aaa #FFF #123456 #999999 #0aF9bc]
    valid_hexcodes.each do |valid_hexcode|
      @tag.color = valid_hexcode
      assert @tag.valid?, "#{valid_hexcode.inspect} should be valid"
    end
  end

  test "color validation should reject invalid hexcodes" do
    invalid_hexcodes = %w[123456 #ab #1234 abcd34 #g12 #-12345]
    invalid_hexcodes.each do |invalid_hexcode|
      @tag.color = invalid_hexcode
      assert_not @tag.valid?, "#{invalid_hexcode.inspect} should be invalid"
    end
  end

  test "should delete" do
    if @tag.save
      @tag.destroy
      assert @tag.destroyed?
    end
  end

  test "should be destroyed if associated project is deleted" do
    @tag.project.destroy && assert_raise(ActiveRecord::RecordNotFound) { @tag.reload }
  end
end
