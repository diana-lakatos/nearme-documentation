module LocationHelper
  def create_location
    visit new_location_path
    @company = model!('company')
    select @company.name, from: 'Company'
    select "USD - United States Dollar", from: "Currency"
    yield if block_given?
    fill_in "Name", with: @location_name = 'Location'
    fill_in "Address", with: '1 Market Street, San Francisco, USA'
    fill_in "Description", with: "There was a house in New Orleans, Bright shining as the sun"
    click_link_or_button "Create Location"
    wait_until { @location = Location.find_by_name(@location_name) }
  end

  def fill_location_form
    fill_in "location_address", with: "Auckland"
    fill_in "location_description", with: "Proin adipiscing nunc vehicula lacus varius dignissim."
    select "Co-working", from: "location_location_type_id"
    fill_in "location_email", with: "location@example.com"
    fill_in "location_special_notes", with: "Special terms are here"
  end

  def assert_location_data(location)
    assert location.address.include?('Auckland') && location.address.include?('New Zealand'), "Expected Auckland in New Zealand, got #{location.address}"
    assert_equal 'Proin adipiscing nunc vehicula lacus varius dignissim.', location.description
    assert_equal 'Co-working', location.location_type.name
    assert_equal 'location@example.com', location.email
    assert_equal 'Special terms are here', location.special_notes
  end
end

World(LocationHelper)
