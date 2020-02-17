require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "invalid signup information" do
    assert_no_difference 'User.count' do
      post '/signup', params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end
    assert_response :unprocessable_entity
    assert @response.body.include? "\"password_confirmation\":[\"doesn't match Password\"]"
    assert @response.body.include? "\"password\":[\"is too short (minimum is 6 characters)\"]"
    assert @response.body.include? "\"name\":[\"can't be blank\"]"
    assert @response.body.include? "\"email\":[\"is invalid\"]"
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post '/signup', params: {
        user: {
          name: "Example User",
          email: "userrr@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    # User receives a confirmation mail
    mail = ActionMailer::Base.deliveries.last
    assert_equal 'userrr@example.com', mail['to'].to_s
    assert_equal 'Confirmation instructions', mail['subject'].to_s
    assert mail.body.to_s.include? "Example User"
    assert mail.body.to_s.include? "<h2>Welcome to the TeamTable!</h2>\n\n<p>Please confirm your email through the link"
    +"below:</p>\n\n<p><a href=\"http://localhost:3001/confirmation?confirmation_token="
  end

end
