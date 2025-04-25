# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules. Add :omniauthable if you plan to use third-party auth later.
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:entra_id]

  # if you want to add new role, update the ROLES array below
  # and add definition methods for the new role
  ROLES = %w[admin dispatcher driver]

  validates :role, inclusion: { in: ROLES }, allow_blank: true

  before_destroy :ensure_at_least_one_admin_remains, if: :admin?

  def admin?
    role == "admin"
  end

  def dispatcher?
    role == "dispatcher"
  end

  def driver?
    role == "driver"
  end

  private
  def ensure_at_least_one_admin_remains
    if User.where(role: "admin").count <= 1
      errors.add(:base, "Cannot delete the last admin user.")
      throw(:abort)
    end
  end
end
