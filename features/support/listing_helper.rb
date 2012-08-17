module ListingHelper
  def create_listing(location, name="Awesome Listing")
    visit new_listing_path
    select location.name, from: "Location"
    fill_in "Name", with: "Awesome Listing"
    fill_in "Description", with: "Nulla rutrum neque eu enim eleifend bibendum."
    fill_in "Quantity", with: "2"
    choose "listing_confirm_reservations_true"
    yield if block_given?
    click_link_or_button("Create Listing")
    wait_until { @listing = Listing.find_by_name(name) }
    store_model('listing', 'user-created listing', @listing)
  end
end
World(ListingHelper)
