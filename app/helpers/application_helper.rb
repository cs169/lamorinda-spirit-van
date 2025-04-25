# frozen_string_literal: true

module ApplicationHelper
  def role_home_path
    return root_path unless current_user

    case current_user.role
    when "admin"
      admin_users_path
    when "dispatcher"
      rides_path
    when "driver"
      drivers_path
    else
      root_path
    end
  end
end
