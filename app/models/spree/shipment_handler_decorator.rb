Spree::ShipmentHandler.class_eval do

  private

  # This is called from shipment handler as well but better to just remove it
  # to avoid raising an error - since we want to remove Spree and having it called 
  # from here was never necessary nor ever worked (just threw an error)
  def send_shipped_email
    # Do nothing
  end

end

