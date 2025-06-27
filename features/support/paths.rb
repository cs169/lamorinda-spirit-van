# frozen_string_literal: true

# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file is used by web_steps.rb, which you should also delete
#
# You have been warned
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the "Log in" page$/ then new_user_session_path
    when /^the "Sign up" page$/ then new_user_registration_path
    when /^the "Home" page$/ then root_path
    when /^the "Lamorinda" page$/ then root_path
    when /^the "New Shift" page$/ then new_shift_path

    when /^the home\s?page$/
      "/"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    when /^the master passenger list$/i
      passengers_path

    when /^the today's rides page$/i
      today_driver_path(1)

    when /^the drivers page$/i
      drivers_path

    when /^the shifts calendar page$/i
      shifts_path

    when /^the shift details page$/i
      shift_path(1)

    when /^the driver's upcoming shifts page$/i
      all_shifts_driver_path(1)

    when /^the admin users page$/i
      admin_users_path

    when /^the rides page$/i
      rides_path

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push("path").join("_").to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
