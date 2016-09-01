class UpdateLinkToCheckoutForJustHala < ActiveRecord::Migration

  def up
    return if Instance.find_by(id: 175).blank?

    ReservationType.find_each { |rt| rt.update_attributes(validate_on_adding_to_cart: "true", skip_payment_authorization: "false") }
    Instance.find_by(id: 175).try(:set_context!)
    return true if PlatformContext.current.nil?
    Instance.find(175).update_attribute(:use_cart, false)
    InstanceView.where(instance_id: 175).find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub('review_listing_reservations_path', 'listing_orders_path').gsub('reservation_request', 'order'))
      new_body = %Q{
        <input value="{{ listing.id }}" type="hidden" name="order[transactable_id]" id="order_transactable_id">
        <input value="{{ listing.action_type.pricings.first.id }}" type="hidden" name="order[transactable_pricing_id]" id="order_transactable_pricing_id">
        <input type="submit" value="Hire Me!">
      }
      unless iv.body.include?('<input value="{{ listing.action_type.pricings.first.id }}" type="hidden" name="order[transactable_pricing_id]" id="order_transactable_pricing_id">')
        iv.update_attribute(:body, iv.body.gsub('<input type="submit" value="Hire Me!">', new_body))
      end
      ReservationType.first.try(:update_attributes, validate_on_adding_to_cart: "false", skip_payment_authorization: "true")
    end
  end

  def down
  end
end

