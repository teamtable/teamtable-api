module AppSecrets
  def self.jwt_secret
    ENV['DEVISE_JWT_SECRET_KEY'].presence ||
      credential(:devise_jwt_secret_key) ||
      'dev-only-insecure-jwt-secret-do-not-use-in-production'
  end

  def self.credential(key)
    Rails.application.credentials.public_send(key)
  rescue StandardError
    nil
  end
end
