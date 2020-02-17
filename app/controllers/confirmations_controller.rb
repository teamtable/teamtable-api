class ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    # TODO: automatically login after confirmation.
    # if resource.errors.empty?
    # set_flash_message!(:notice, :confirmed)
    redirect_to after_confirmation_path_for(resource_name, resource)
    # else
    # redirect_to after_confirmation_path_for(resource_name, resource)
    # end
  end

  protected

  def after_confirmation_path_for(_resource_name, _resource)
    # sign_in(resource) # In case you want to sign in the user
    'https://teamtable.herokuapp.com/login'
  end
end
