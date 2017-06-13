class GeneratePaymentJob < Job
  def after_initialize(class_name, period_id)
    @period_id = period_id
    @payable_class = class_name.constantize
  end

  def perform
    period = @payable_class.find(@period_id)
    period.instance.set_context!
    period.generate_payment!
  end
end
