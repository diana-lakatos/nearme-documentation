Given /^(Location|Listing) with my details should be created$/ do |model|
  if model=='Location'
    location = Location.last
    assert_location_data(location)
  else
    listing = Listing.last
    assert_listing_data(listing)
  end
end

Given /^#{capture_model} should be updated$/ do |model|
  if model=='the location'
    location = model!('location')
    assert_location_data(location)
  else
    listing = model!('listing')
    assert_listing_data(listing, true)
  end
end

When /^I fill (location|listing) form with valid details$/ do |model|
  if model == 'location'
    fill_location_form
  else 
    fill_listing_form
  end
end

When /^I (disable|enable) (.*) pricing$/ do |action, period|
  page.find("#enable_#{period}").set(action == 'disable' ? false : true)
  if action=='enable'
    page.find("#listing_#{period}_price").set(15.50)
  end

end

When /^I provide new (location|listing) data$/ do |model|
  if model == 'location'
    fill_location_form
  else 
    fill_listing_form
  end
end

When /^I submit the form$/ do
  page.find('#submit-link').click
end

When /^I click edit icon$/ do
  page.find('section.dashboard .ico-edit').click
end

When /^I click edit listing icon$/ do
  page.find('.listing .ico-edit').click
end

When /^I click delete location link$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  click_link "Delete this location"
end

When /^I click delete bookable noun link$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  click_link "Delete this #{model!("instance").bookable_noun}"
end

Then /^Listing (.*) pricing should be (disabled|enabled)$/ do |period, state|
  enable_period_checkbox = page.find("#enable_#{period}")
  if state=='enabled'
    assert enable_period_checkbox.checked?
    assert_equal "15.50", page.find("#listing_#{period}_price").value
  else
    assert !enable_period_checkbox.checked?
  end
end

Then /^pricing should be free$/ do
  page.find("#listing_price_type_free").checked?
end

When /^I select custom availability:$/ do |table|
  choose 'availability_rules_custom'

  days = availability_data_from_table(table)
  days.each do |day, rule|
    within ".availability-rules .day-#{day}" do
      if rule.present?
        page.find('.open-checkbox').set(true)
        page.find("select[name*=open_time] option[value='#{rule[:open]}']").select_option
        page.find("select[name*=close_time] option[value='#{rule[:close]}']").select_option
      else
        page.find('.open-checkbox').set(false)
      end
    end
  end
end

Then /^#{capture_model} should have availability:$/ do |model, table|
  object = model!(model)
  days = availability_data_from_table(table)

  object.availability.each_day do |day, rule|
    if days[day].present?
      assert rule, "#{day} should have a rule"
      oh, om = days[day][:open].split(':').map(&:to_i)
      ch, cm = days[day][:close].split(':').map(&:to_i)
      assert_equal oh, rule.open_hour, "#{day} should have open hour = #{oh}"
      assert_equal om, rule.open_minute, "#{day} should have open minute = #{om}"
      assert_equal ch, rule.close_hour, "#{day} should have close hour = #{ch}"
      assert_equal cm, rule.close_minute, "#{day} should have close minute = #{cm}"
    else
      assert_nil rule, "#{day} should not be open"
    end
  end
end

