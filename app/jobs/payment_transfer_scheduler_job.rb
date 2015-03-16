# Schedules PaymentTransfers for successfully paid payments by users.
#
# PaymentTransfers then need to be paid by the admin and flagged as such.
class PaymentTransferSchedulerJob < Job
  def perform
    Company.needs_payment_transfer.uniq.find_each do |company|
      SchedulePaymentTransferJob.perform(company.id) if PaymentTransfers::SchedulerMethods.new(company.instance).generate_payment_transfers_today?
    end
  end
end
