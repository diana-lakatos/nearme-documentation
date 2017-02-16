class PaymentBaseDecorator < Draper::Decorator
  def new_payment_source(payment_method)
    payment_method.payment_sources.new
  end

  def payment_sources_collection(payment_method)
    all_payment_sources_collection(payment_method) << new_payment_source_for_collection(payment_method)
  end

  def default_payment_source(payment_method)
    return to_option(payment_source) if payment_source && payment_source.payment_method == payment_method 

    all_payment_sources_collection(payment_method).first || to_option(new_payment_source(payment_method) )
  end

  def all_payment_sources(payment_method)
    payment_method.payment_sources.where(instance_client: instance_clients(payment_method.payment_gateway_id), test_mode: instance.test_mode?).reverse
  end

  def instance_clients(pg_id)
    payer.instance_clients.for_payment_gateway(pg_id, instance.test_mode?)
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end

  private

  def all_payment_sources_collection(payment_method)
    (all_payment_sources(payment_method).try(:map) do |payment_source|
      to_option(payment_source)
    end || [])
  end

  def new_payment_source_for_collection(payment_method)
    [I18n.t("payments.#{payment_method.payment_method_type}.add_new"), 'new_' + payment_method.payment_method_type]
  end

  def to_option(model)
    return ['new_' + model.payment_method.payment_method_type] unless model.persisted?
    [model.name, model.id]
  end
end
