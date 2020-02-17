class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  respond_to :json

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_locale

  protected

  def configure_permitted_parameters
    # permit additional parameter :name
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation) }
    update_attrs = [:name, :email, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  def current_user_id
    token = request.headers.fetch('Authorization').split(' ').last
    secret = Rails.application.credentials.devise_jwt_secret_key
    payload = JWT.decode(token, secret)
    payload.first.values.first.to_i # return subject (user_id)
  end

  def authorized_for_card?(card)
    return true if card.list.project.users.exists?(current_user_id)
    head :unauthorized
    false
  end

  def authorized_for_list?(list)
    return true if list.project.users.exists?(current_user_id)
    head :unauthorized
    false
  end

  def authorized_for_tag?(tag)
    return true if tag.project.users.exists?(current_user_id)
    head :unauthorized
    false
  end

  def update_current_project(project_id)
    User.find(current_user_id).update_current_project project_id
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
