module ListingsHelpers
  def listing
    @listing = model!("listing") if(!@listing)
    @listing
  end
end
World(ListingsHelpers)
