class SchedulePaymentTransferJob < Job
  def after_initialize(company_id)
    @company = Company.with_deleted.find(company_id)
  end

  def perform
    PlatformContext.current = PlatformContext.new(@company.instance)
    @company.schedule_payment_transfer
  end
end
