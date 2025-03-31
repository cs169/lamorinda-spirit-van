# Given('I am on the passengers page') do
#   visit 'passengers_path'
#   save_and_open_page
# end

Then('the {string} column should be visible') do |column_name|
  expect(page).to have_button("JS Ran!", wait: 10)

  table = find('#passengers-table')
  header = table.find('thead').find('tr')
  expect(header).to have_content(column_name)
end

Then('the {string} column should be hidden') do |column_name|
  table = find('#passengers-table')
  header = table.find('thead').find('tr')
  expect(header).not_to have_content(column_name)
end

When('I uncheck the {string} column toggle') do |column_name|
  checkbox = find(:xpath, '/html/body/div/div/div/div/div[1]/div[8]/label')
  checkbox.uncheck
end

When('I check the {string} column toggle') do |column_name|
  checkbox = find("#column-toggle-container label", text: column_name).sibling('input')
  checkbox.check
end

Given('I have hidden the {string} column') do |column_name|
  step "I uncheck the \"#{column_name}\" column toggle"
  step "the \"#{column_name}\" column should be hidden"
end