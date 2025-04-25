# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action -> { require_role("admin") }

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully."
    else
      redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  def destroy_unassigned
    # Search for users with nil or empty role, delete them, return the count number
    deleted_count = User.where(role: [nil, ""]).delete_all

    # Redirects back to the admin users index page with a flash message
    redirect_to admin_users_path, notice: "#{deleted_count} unassigned users removed."
  end

  private
  def user_params
    permitted = [:email, :password]
    # Allow admin to update role, but regular users can only update email and password
    permitted << :role if current_user&.admin?
    params.require(:user).permit(permitted)
  end
end
