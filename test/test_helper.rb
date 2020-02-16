require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module MiniTestWithBullet
  require 'minitest/unit'

  def before_setup
    Bullet.start_request
    super if defined?(super)
  end

  def after_teardown
    super if defined?(super)
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def log_in_as(user, password = 'password')
      user.confirm
      post '/login', params: { user: { email: user.email, password: password } }
      @authorization_token = @response.get_header("Authorization")
    end

    def response_body_include?(params)
      params.each do |param|
        assert (response.body.include? param), "#{param} should be included in response body"
      end
    end

    def response_body_not_include?(params)
      params.each do |param|
        assert_not (response.body.include? param), "#{param} should not be included in response body"
      end
    end
    # Add more helper methods to be used by all tests here...
  end
end
