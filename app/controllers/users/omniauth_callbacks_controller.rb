# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def entra_id
    data = request.env["omniauth.auth"]["info"]
    @user = User.find_by(email: data["email"])
    @user ||= User.create(email: data["email"], password: Devise.friendly_token[0, 20])
    if @user.persisted?
      flash[:notice] = "success"
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:notice] = "failed"
      redirect_to new_user_session_path
    end
  end
end
