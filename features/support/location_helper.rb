module LocationHelper
  def create_location
    visit new_location_path
    @company = model!('company')
    select @company.name, from: 'Company'
    yield if block_given?
    fill_in "Name", with: @location_name = 'Location'
    fill_in "Address", with: '1 Market Street, San Francisco, USA'
    fill_in "Description", with: "There was a house in New Orleans, Bright shining as the sun"
    click_link_or_button "Create Location"
    wait_until { @location = Location.find_by_name(@location_name) }
  end
end
World(LocationHelper)
