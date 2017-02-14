class PaymentSubscriptionDecorator < PaymentBaseDecorator
  include Draper::LazyHelpers
  delegate_all
end
