class PaymentSubscriptionDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def new_payment_source(payment_method)
    payment_method.payment_sources.new
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

  def self.collection_decorator_class
    PaginatingDecorator
  end
end
