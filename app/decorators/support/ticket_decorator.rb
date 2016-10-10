class Support::TicketDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def show_target_path(options = {})
    target_with_deleted = target_type.constantize.respond_to?(:with_deleted) ? target_type.constantize.with_deleted.find(target_id) : target
    target_with_deleted.decorate.show_path(options)
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def messages
    Support::TicketMessageDecorator.decorate_collection(super)
  end
end
