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

  def alerts
    alerts_container = []

    if paid? && refunds.any?
      if should_retry_refund?
        alerts_container << I18n.t("decorators.payment.refund_retry_at", retry_at: l(self.retry_refund_at, format: :long))
      else
        alerts_container << I18n.t("decorators.payment.refund_failed")
      end
    end

  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end

