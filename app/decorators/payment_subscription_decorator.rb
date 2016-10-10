class PaymentSubscriptionDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end
end
