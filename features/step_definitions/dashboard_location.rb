Given /^(Location|Listing) with my details should be created$/ do |model|
  if model=='Location'
    location = Location.last
    assert_location_data(location)
  else
    listing = Transactable.last
    assert_listing_data(listing)
  end
end

Given /^TransactableType is for bulk upload$/ do
  FactoryGirl.create(:transactable_type_current_data)
end

When /^I upload csv file with locations and transactables$/ do
  FactoryGirl.create(:location_type, name: 'My Type')
  Utils::DefaultAlertsCreator::DataUploadCreator.new.notify_uploader_of_finished_import_email!
  click_link 'Bulk upload'
  stub_image_url('http://www.example.com/image1.jpg')
  stub_image_url('http://www.example.com/image2.jpg')
  work_in_modal('.dialog[aria-hidden="false"]') do
    page.should have_css('#new_data_upload')
    attach_file('data_upload_csv_file', File.join(Rails.root, *%w[test assets data_importer current_data.csv]))
    click_button 'Import'
  end
  page.should_not have_css('#new_data_upload')
end

Then /^I should receive data upload report email when finished$/ do
  mails = emails_for(model!('user').email)
  assert_equal 1, mails.count
  mail = mails.first
  assert_equal "[DesksNearMe] Importing 'current_data.csv' has finished", mail.subject
end

Then /^New locations and transactables from csv should be added$/ do
  company = model!('user').companies.first
  assert_equal ['Czestochowa', 'Rydygiera'], company.locations.pluck(:name).compact.sort
  assert_equal [["my name", "Rydygiera"], ["my name2", "Rydygiera"]], company.listings.joins(:location).where('locations.name IS NOT NULL').select('transactables.id, transactables.name, locations.name as location_name, transactable_type_id, properties').sort.map { |l| [l.name, l.location_name] }
end

Given /^#{capture_model} should be updated$/ do |model|
  if model=='the location'
    location = Location.last
    assert_location_data(location)
    page.should have_content(location.name)
  else
    listing = Transactable.first
    assert_listing_data(listing, true)
  end
end

When /^I fill (location|listing) form with valid details$/ do |model|
  if model == 'location'
    fill_location_form
  else
    fill_listing_form
  end
  wait_for_ajax
end

When /^I (disable|enable) (.*) pricing$/ do |action, period|
  click_link 'Pricing & Availability'
  if action=='enable'
    page.execute_script("$(\"[data-pricing-for='#{period}'] input[name*='enabled'][type=checkbox]\").prop('checked', true)")
    page.execute_script("$(\"[data-pricing-for='#{period}'] input[name*='enabled'][type=checkbox]\").trigger('change')")
    page.find("[data-pricing-for='#{period}'] input[name*='price'][type=number]").set(15.50)
  else
    page.execute_script("$(\"[data-pricing-for='#{period}'] input[name*='enabled'][type=checkbox]\").prop('checked', false)")
    page.execute_script("$(\"[data-pricing-for='#{period}'] input[name*='enabled'][type=checkbox]\").trigger('change')")
  end
end

When /^I provide new (location|listing) data$/ do |model|
  if model == 'location'
    fill_location_form
  else
    fill_listing_form
  end
end

When /^I submit the location form$/ do
  page.execute_script("$(\"#location-form input[type=submit]\").click()")
  wait_for_ajax
end

When /^I submit the transactable form$/ do
  page.find('#listing-form input[type=submit]').click
end

When /^I submit the form$/ do
  page.find('#submit-input').click
end

When /^I click edit location icon$/ do
  page.find('.location .edit').click
end

When /^I click edit listing icon$/ do
  page.find('.listing .edit').click
end

When /^I click delete location link$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  click_link "Delete this location"
end

When /^I click delete bookable noun link$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  click_link "Delete this #{model!('theme').bookable_noun}"
end

Then /^Listing (.*) pricing should be (disabled|enabled)$/ do |period, state|
  click_link 'Pricing & Availability'
  enable_period_checkbox = page.find("[data-pricing-for='#{period}'] input[name*='enabled'][type=checkbox]")
  if state=='enabled'
    assert enable_period_checkbox.checked?
    assert_equal "15.50", page.find("[data-pricing-for='#{period}'] input[name*='price'][type=number]").value
  else
    assert !enable_period_checkbox.checked?
  end
end

When /^I mark (.*) price as free$/ do |period|
  page.execute_script("$(\"[data-pricing-for='#{period}'] input[name*='is_free_booking'][type=checkbox]\").click()")
end

Then /^pricing for (.*) should be free$/ do |period|
  click_link 'Pricing & Availability'
  page.find("[data-pricing-for='#{period}'] input[name*='is_free_booking'][type=checkbox]", visible: false).checked?
end

When /^I select custom availability:$/ do |table|
  click_link 'Pricing & Availability'
  first('.transactable_action_types_availability_template_id li:last-child').click
  (0..6).each do |day|
    page.execute_script("$(\"input.check_boxes[id$='_days_#{day}']\").prop('checked', false)")
    page.execute_script("$(\"input.check_boxes[id$='_days_#{day}']\").trigger('change')")
  end
  rules = availability_data_from_table(table)
  rules.each do |rule|

    page.execute_script("$(\"input.time_picker[id$='_open_time']\").timepicker('setTime', '#{rule[:open]}')")
    page.execute_script("$(\"input.time_picker[id$='_close_time']\").timepicker('setTime', '#{rule[:close]}')")

    rule[:days].each do |day|
      page.execute_script("$(\"input.check_boxes[id$='_days_#{day}']\").prop('checked', true)")
      page.execute_script("$(\"input.check_boxes[id$='_days_#{day}']\").trigger('change')")
    end
  end
end

Then /^#{capture_model} should have availability:$/ do |model, table|
  object = model!(model)
  rules = availability_data_from_table(table)
  availability = object.availability
  rules.each do |rule|
    rule[:days].each do |day|
      availability_rule = availability.rules_for_day(day).first
      assert availability_rule, "#{day} should have a rule"
      oh, om = rule[:open].split(':').map(&:to_i)
      ch, cm = rule[:close].split(':').map(&:to_i)
      assert_equal oh, availability_rule.open_hour, "#{day} should have open hour = #{oh}"
      assert_equal om, availability_rule.open_minute, "#{day} should have open minute = #{om}"
      assert_equal ch, availability_rule.close_hour, "#{day} should have close hour = #{ch}"
      assert_equal cm, availability_rule.close_minute, "#{day} should have close minute = #{cm}"
    end
    ((0..6).to_a - rule[:days]).each do |day|
      refute availability.rules_for_day(day).first, "#{day} should not have a rule"
    end
  end
end
