class PaymentDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def state
    if refunded_at?
      'Refunded'
    elsif paid_at?
      'Captured'
    elsif failed_at?
      'Failed'
    end
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end

