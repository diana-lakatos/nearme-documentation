module ListingsHelpers
  def create_listing(location, name="Awesome Listing")
    visit new_manage_location_listing_url(location)
    create_listing_without_visit(location, name) do
      yield if block_given?
    end
  end

  def create_listing_without_visit(location, name="Awesome Listing")
    try_to_create_listing(location, name) do
      yield if block_given?
    end
    wait_until { @listing = Listing.find_by_name(name) }
    store_model('listing', 'user-created listing', @listing)
  end

  def try_to_create_listing(location, name="Awesome Listing")
    fill_in "Name", with: name
    fill_in "Description", with: "Nulla rutrum neque eu enim eleifend bibendum."
    fill_in "Quantity", with: "2"
    choose "listing_confirm_reservations_true"
    select "Desk"
    yield if block_given?
    click_link_or_button("Create Listing")
  end



  def set_hidden_field id, value
    page.execute_script("$('##{id}').val('#{value}')")
  end

  def listing
    @listing = model!("listing") if(!@listing)
    @listing
  end

  def create_listing_in(city)
    instance_variable_set "@listing_in_#{city.downcase.gsub(' ', '_')}",
      FactoryGirl.create("listing_in_#{city.downcase.gsub(' ', '_')}")
  end
end
World(ListingsHelpers)
