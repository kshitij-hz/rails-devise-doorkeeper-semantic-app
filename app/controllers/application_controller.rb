class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?


  # clear_respond_to
  # respond_to :json

  before_action :authenticate, unless: :devise_controller?

  def authenticate
    if !user_signed_in?
      doorkeeper_authorize!
      if doorkeeper_token.present?
        @current_user = User.find(doorkeeper_token.resource_owner_id)
      end
    end
    if doorkeeper_token.blank? && @current_user.blank?
      authenticate_user! 
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: errors_json(e.message), status: :not_found
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :current_password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation])
  end  

  private

  def errors_json(messages)
    { errors: [*messages] }
  end


end
