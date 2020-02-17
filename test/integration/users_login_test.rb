require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:alice)
  end

  test "Login with invalid information" do
    @user.confirm
    assert_no_difference '@user.sign_in_count' do
      post '/login', params: { session: { email: '', password: '' } }
      @user.reload
    end
    assert_response :unauthorized
  end

  test "Login with wrong email or password" do
    @user.confirm
    assert_no_difference '@user.sign_in_count' do
      post '/login', params: { user: { email: @user.email, password: '12345678' } }
      assert_response :unauthorized
      assert_equal "{\"error\":\"Invalid Email or password.\"}", @response.body

      post '/login', params: { user: { email: "abc@test.de", password: 'password' } }
      assert_response :unauthorized
      assert_equal "{\"error\":\"Invalid Email or password.\"}", @response.body
      @user.reload
    end
  end

  test "Email confirmation required before login" do
    # Users email needs to be confirmed before he can sign in
    assert_no_difference '@user.sign_in_count' do
      post '/login', params: { user: { email: @user.email, password: 'password' } }
      @user.reload
    end
    assert_response :unauthorized
    assert_not @response.has_header?("Authorization")
    assert_equal "{\"error\":\"You have to confirm your email address before continuing.\"}", @response.body

  end

  test "Login after email confirmation" do
    @user.confirm
    assert_difference '@user.sign_in_count', 1 do
      post '/login', params: { user: { email: @user.email, password: 'password' } }
      @user.reload
    end
    assert_response :ok
    assert @response.has_header?("Authorization")
    assert @response.get_header("Authorization").include? "Bearer "
  end

  test "Update password, when logged in" do
    log_in_as(@user)
    assert_response :ok

    put '/signup', params: { user: {
      password: 'new password', password_confirmation: 'new password', current_password: 'password'
    } }, headers: { Authorization: @authorization_token }

    # try login with old password
    log_in_as(@user)
    assert_response :unauthorized

    # login with new password
    log_in_as(@user, 'new password')
    assert_response :ok
  end

  test "Update password after logout" do
    log_in_as(@user)

    delete '/logout', params: { user: { email: @user.email, password: 'password' } },
           headers: { Authorization: @authorization_token }

    put '/signup', params: { user: {
      password: 'new password', password_confirmation: 'new password', current_password: 'password'
    } }, headers: { Authorization: @authorization_token }

    # try login with old password, which is still valid
    log_in_as(@user)
    assert_response :ok

    # login with new password, which is invalid
    log_in_as(@user, password: 'new passowrd')
    assert_response :unauthorized
  end
end
