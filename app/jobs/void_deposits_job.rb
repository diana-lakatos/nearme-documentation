class VoidDepositsJob < Job
  def perform
    Reservation.where("ends_at <= ?", Time.current - 24.hours).joins(:deposit).where('deposits.voided_at is NULL').find_each do |reservation|
      if reservation.deposit
        DepositVoidJob.perform(reservation.deposit.payment.id)
      end
    end
  end
end
