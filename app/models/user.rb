# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules. Add :omniauthable if you plan to use third-party auth later.
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # :omniauthable, omniauth_providers: [:google_oauth2]

  # if you want to add new role, update the ROLES array below
  # and add definition methods for the new role
  ROLES = %w[admin dispatcher driver]

  validates :role, inclusion: { in: ROLES }, allow_blank: true


  def admin?
    role == "admin"
  end

  def dispatcher?
    role == "dispatcher"
  end

  def driver?
    role == "driver"
  end
end
