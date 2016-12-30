# frozen_string_literal: true
class PaymentDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def alerts
    alerts_container = []

    if paid? && refunds.any?
      if should_retry_refund?
        alerts_container << I18n.t('decorators.payment.refund_retry_at', retry_at: l(retry_refund_at, format: :long))
      else
        alerts_container << I18n.t('decorators.payment.refund_failed')
      end
    end
    alerts_container
  end

  def payment_sources_collection(payment_method)
    (all_payment_sources(payment_method).try(:map) do |payment_source|
      [payment_source.name, payment_source.id]
    end || []) << [I18n.t("payments.#{payment_method.payment_method_type}.add_new"), 'new_' + payment_method.payment_method_type]
  end

  def all_payment_sources(payment_method)
    payment_method.payment_sources.where(instance_client: instance_clients(payment_method.payment_gateway_id), test_mode: instance.test_mode?)
  end

  def instance_clients(pg_id)
    payer.instance_clients.for_payment_gateway(pg_id, instance.test_mode?)
  end

  def new_payment_source(payment_method)
    payment_method.payment_sources.new
  end

  def payment_methods
    ids = if is_free?
            payment_gateways.map(&:active_free_payment_methods)
          else
            payment_gateways.map(&:active_payment_methods)
    end.flatten.uniq.map(&:id)

    PaymentMethod.where(id: ids)
  end

  def host_payment_methods
    payment_gateways.map(&:active_payment_methods).flatten.uniq
  end

  def payment_gateways
    @payment_gateways ||= PlatformContext.current.instance.payment_gateways(company.iso_country_code, currency)
  end

  def payment_gateway_url
    payment_gateway.payment_url(self)
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end
