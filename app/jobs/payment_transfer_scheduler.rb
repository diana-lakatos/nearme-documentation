# Schedules PaymentTransfers for successfully paid payments by users.
#
# PaymentTransfers then need to be paid by the admin and flagged as such.
class PaymentTransferScheduler
  def perform
    Company.needs_payment_transfer.find_each do |company|
      company.schedule_payment_transfer
    end
  end
end
