class SchedulePaymentTransferJob < Job

  def after_initialize(company_id)
    @company = Company.with_deleted.find(company_id)
    PlatformContext.current = PlatformContext.new(company.instance)
  end

  def perform
    @company.schedule_payment_transfer
  end

end

