require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "send email on successful registration" do
    # Asserts the difference in the ActionMailer::Base.deliveries
    assert_emails 1 do
      post '/signup', params: { user: {
        name: "Name",
        email: "example@mail.com",
        password: "password",
        password_confirmation: "password"
      } }
    end
  end

  test "do not send email on failed registration" do
    # Asserts the difference in the ActionMailer::Base.deliveries
    assert_emails 0 do
      post '/signup', params: { user: {
        name: "Name",
        email: "invalid",
        password: "password",
        password_confirmation: "password"
      } }

      post '/signup', params: { user: {
        name: "Name",
        email: "example@mail.com",
      } }
    end
  end

  test "should require email confirmation" do
    @user = users(:alice)
    post '/login', params: { user: { email: @user.email, password: "password" } },
         headers: { Authorization: @authorization_token }, as: :json
    assert_response :unauthorized
    response_body_include? ["{\"error\":\"You have to confirm your email address before continuing.\"}"]
  end
end
