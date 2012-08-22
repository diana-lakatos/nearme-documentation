module ListingsHelpers
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
