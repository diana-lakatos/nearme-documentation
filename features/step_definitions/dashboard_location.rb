Given /^(Location|Listing) with my details should be created$/ do |model|
  if model=='Location'
    location = Location.last
    assert_location_data(location)
  else
    listing = Transactable.last
    assert_listing_data(listing)
  end
end

Given /^#{capture_model} should not be pickable$/ do |model|
  location = Location.with_deleted.last
  within('.edit-locations') do
    page.should_not have_content(location.name, visible: true)
  end
  assert_not_nil location.deleted_at
end

Given /^TransactableType is for bulk upload$/ do
  FactoryGirl.create(:transactable_type_current_data)
end

When /^I upload csv file with locations and transactables$/ do
  FactoryGirl.create(:location_type, name: 'My Type')
  Utils::DefaultAlertsCreator::DataUploadCreator.new.notify_uploader_of_finished_import_email!
  find(:css, 'a.bulk-upload').click
  stub_image_url('http://www.example.com/image1.jpg')
  stub_image_url('http://www.example.com/image2.jpg')
  work_in_modal do
    page.should have_css('#new_data_upload')
    attach_file('data_upload_csv_file', File.join(Rails.root, *%w[test assets data_importer current_data.csv]))
    find('.btn-toolbar input[type=submit]').click
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
    page.should have_content(location.name, visible: true)
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
  page.find("#enable_#{period}").set(action == 'disable' ? false : true)
  if action=='enable'
    if page.has_selector?("#listing_#{period}_price")
      page.find("#listing_#{period}_price").set(15.50)
    else
      page.find("#transactable_#{period}_price").set(15.50)
    end
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
  page.find('#location-form input[type=submit]').click
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
  enable_period_checkbox = page.find("#enable_#{period}")
  if state=='enabled'
    assert enable_period_checkbox.checked?
    if page.has_selector?("#listing_#{period}_price")
      assert_equal "15.50", page.find("#listing_#{period}_price").value
    else
      assert_equal "15.50", page.find("#transactable_#{period}_price").value
    end
  else
    assert !enable_period_checkbox.checked?
  end
end

Then /^pricing should be free$/ do
  if page.has_selector?("#listing_price_type_free")
    page.find("#listing_price_type_free").checked?
  else
    page.find("#transactable_action_free_booking").checked?
  end
end

When /^I select custom availability:$/ do |table|
  choose 'availability_rules_custom'
  (0..6).each do |day|
    page.find("#transactable_availability_template_attributes_availability_rules_attributes_0_days_#{day}").set(false)
  end
  rules = availability_data_from_table(table)
  rules.each do |rule|
    fill_in "transactable_availability_template_attributes_availability_rules_attributes_0_open_time", with: rule[:open]
    fill_in "transactable_availability_template_attributes_availability_rules_attributes_0_close_time", with: rule[:close]
    rule[:days].each do |day|
      page.find("#transactable_availability_template_attributes_availability_rules_attributes_0_days_#{day}").set(true)
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
