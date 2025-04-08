Then('the {string} column should be visible') do |column_name|




  
  # puts all("span.dt-column-title", visible: :true).map(&:text)

    titles = all("span.dt-column-title", visible: :all).map(&:text).map(&:strip)
    expect(titles).to include(column_name), "Expected to find column '#{column_name}', but only found: #{titles.inspect}"
  # puts page.html

  # using_wait_time 5 do
    # Get all header titles inside <span class="dt-column-title">
    # headers = all('.dt-column-title', visible: true).map(&:text).map(&:strip)

    # expect(headers).to include(column_name), "Expected to find column '#{column_name}', but found: #{headers}"
  #   page.execute_script("const el = document.querySelector('.dataTables_scrollBody'); if (el) el.scrollLeft = el.scrollWidth;")
  #   expect(page).to have_selector('th', text: column_name, visible: true)
  # # end
end

Then('the {string} column should be hidden') do |column_name|
  table = find('#passengers-table')
  header = table.find('thead').find('tr')
  expect(header).not_to have_content(column_name)
end

When('I uncheck the {string} column toggle') do |column_name|
  uncheck column_name
  sleep 5
end

When('I check the {string} column toggle') do |column_name|
  check column_name
end

Given('I have hidden the {string} column') do |column_name|
  step "I uncheck the \"#{column_name}\" column toggle"
  step "the \"#{column_name}\" column should be hidden"
end

