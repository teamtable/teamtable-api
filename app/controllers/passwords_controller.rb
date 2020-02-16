class PasswordsController < Devise::PasswordsController
  protected

  def after_sending_reset_password_instructions_path_for(_resource_name)
    'https://teamtable.herokuapp.com/password-reset-instructions'
  end
end
