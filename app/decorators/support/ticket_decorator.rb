class Support::TicketDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def show_target_path(options = {})
    target_with_deleted = self.target_type.constantize.respond_to?(:with_deleted) ? self.target_type.constantize.with_deleted.find(self.target_id) : self.target
    if Transactable === target_with_deleted
      transactable_type_location_listing_path(target_with_deleted.transactable_type, target_with_deleted.location, target_with_deleted, options)
    elsif Spree::Product === target_with_deleted
      product_path(target_with_deleted, options)
    end
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def messages
    Support::TicketMessageDecorator.decorate_collection(super)
  end
end
