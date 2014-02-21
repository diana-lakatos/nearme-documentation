# Schedules PaymentTransfers for successfully paid payments by users.
#
# PaymentTransfers then need to be paid by the admin and flagged as such.
class PaymentTransferSchedulerJob < Job
  def perform
    Company.needs_payment_transfer.find_each do |company|
      PlatformContext.current = PlatformContext.new(company)
      company.schedule_payment_transfer
    end
  end
end
