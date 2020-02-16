require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  def setup
    @user = users(:alice)
  end

  test "send email with password-reset instructions" do
    # Asserts the difference in the ActionMailer::Base.deliveries
    assert_emails 2 do
      post '/password', params: { user: { email: "testuserrr@gmx.de" } }
      post '/password', params: { user: { email: "testuserrr@gmx.de" }, locale: "de" }
    end
  end

  test "include link to password-reset in response, when password-reset-instructions is requested" do
    post '/password', params: { user: { email: "testuserrr@gmx.de" } }
    assert_equal 'https://teamtable.herokuapp.com/password-reset-instructions', response.location
  end

  test "do not send email, if email does not belong to a user" do
    # Asserts the difference in the ActionMailer::Base.deliveries
    assert_emails 0 do
      post '/password', params: { user: {
        email: "a@bc.de",
      } }

      post '/password', params: { user: {
        email: "invalid",
      } }
    end
  end
end
