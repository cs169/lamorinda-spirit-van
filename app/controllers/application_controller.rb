# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Ensures that all actions (except Devise controllers) require a logged-in user.
  # Unauthenticated users will be redirected to the sign-in page.
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevents users without a role from accessing the system.
  # If a signed-in user has no assigned role, they will be signed out and redirected with a message.
  before_action :check_user_role, if: :user_signed_in?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
  end

  def check_user_role
    if current_user.role.blank?
      sign_out(current_user)
      redirect_to new_user_session_path, alert: "Your account is awaiting role assignment. Please contact an admin."
    end
  end

  def require_role(*roles)
    unless roles.include?(current_user.role)
      # If the user was on a specific page and they don't have the required role,
      # redirect them to the root path with an alert message.
      if request.path != root_path
        redirect_to root_path, alert: "Access denied."
      end
    end
  end

  # @Override
  def after_sign_in_path_for(resource)
    role_home_path
  end
end
