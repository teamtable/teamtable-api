require 'test_helper'

class InternationalizationTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:alice), users(:bob), users(:clara)]
    log_in_as(@users[0])
  end

  test "send email confirmation mail in german" do
    @user = users(:alice)
    post '/login', params: { user: { email: @user.email, password: "wrong password" }, locale: "de" }, as: :json
    response_body_include? ["{\"error\":\"E-Mail oder Passwort ungültig.\"}"]
  end

  test "respond with german message on validation error" do
    post projects_url, params: { project: { title: "" }, locale: "de" },
         headers: { Authorization: @authorization_token }, as: :json
    response_body_include? ["{\"message\":\"Gültigkeitsprüfung ist fehlgeschlagen: Title muss ausgefüllt werden\"}"]
  end
end
