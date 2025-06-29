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

  # Captures a `return_to`-like parameter into session storage.
  # Accepts a session key to differentiate between different controllers.
  def capture_return_to(session_key = :return_to)
    if params[session_key].present?
      session[session_key] = params[session_key]
    end
    instance_variable_set("@#{session_key}", session[session_key])
  end

  # Clears a previously captured `return_to`-like parameter from session.
  # Should be called once the user navigates back to the intended page.
  def clear_return_to(session_key = :return_to)
    session.delete(session_key)
  end

  # Securely validate return URL to prevent open redirects and XSS
  def safe_return_url
    return nil unless params[:return_url].present?

    begin
      uri = URI.parse(params[:return_url])

      # Only allow relative URLs (no scheme, no host)
      # This prevents external redirects and javascript: schemes
      if uri.scheme.nil? && uri.host.nil? && uri.path.start_with?("/")
        # Additional validation: ensure the path doesn't contain dangerous patterns
        path = uri.path
        return nil if path.include?("..") || path.include?("javascript:")

        # Reconstruct URL with only safe components (path + query)
        url = path
        url += "?#{uri.query}" if uri.query.present?
        url += "##{uri.fragment}" if uri.fragment.present?

        return url
      end
    rescue URI::InvalidURIError
      # Invalid URI format - return nil for safety
    end
    nil
  end
end
