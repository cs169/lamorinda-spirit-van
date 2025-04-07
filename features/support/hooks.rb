# frozen_string_literal: true

Before("@headful") do
    Capybara.current_driver = :selenium_chrome
    page.driver.browser.manage.window.resize_to(1280, 900)
  rescue Selenium::WebDriver::Error::WebDriverError => e
    puts "[WARNING] Falling back to default driver due to error: #{e.message}"
    Capybara.current_driver = :rack_test
  end
