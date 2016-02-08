class PaymentDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def alerts
    alerts_container = []

    if paid? && refunds.any?
      if should_retry_refund?
        alerts_container << I18n.t("decorators.payment.refund_retry_at", retry_at: l(self.retry_refund_at, format: :long))
      else
        alerts_container << I18n.t("decorators.payment.refund_failed")
      end
    end

    alerts_container = []
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end

