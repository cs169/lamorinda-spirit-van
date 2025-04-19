# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@lovelafayette.org" # This currently doesn't do anything
  layout "mailer"
end
