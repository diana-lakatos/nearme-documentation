class Billing::Gateway::Processor::Outgoing::Base < Billing::Gateway::Processor::Base

  def initialize(receiver, currency)
    @instance = @sender = receiver.instance
    @client = @receiver = receiver
    @currency = currency
    setup_api_on_initialize
  end

  def payout(payout_details)
    amount, reference = payout_details[:amount], payout_details[:reference]
    raise Billing::Gateway::Processor::Base::InvalidStateError.new("Unexpected state, amounts currency is different from the one that initialized processor") if amount.currency.iso_code != @currency
    @payout = Payout.create(
      amount: amount.cents,
      currency: amount.currency.iso_code,
      reference: reference
    )
    process_payout(amount)
    if @payout.should_be_verified_after_time?
      # seems that in order to support this, we need to upgrade balanced gem to use 1.1v of api.
      # As you might guess, ths will break most of what we have currently :)
      # PayoutVerificationJob.perform_later(4.days.from_now, self)
    end
    @payout
  end

  def update_payout_status(payout)
    return false unless status_updateable? && payout.present?
    @payout = payout
    update_payout_status_process(@payout.verify_after_time_arguments)
  end

  # Contains implementation for transferring money to company
  def process_payout
    raise NotImplementedError
  end

  def status_updateable?
    false
  end

  protected

  # Callback invoked by processor when payout was successful
  def payout_successful(response)
    @payout.payout_successful(response)
  end

  # Callback invoked by processor when payout failed
  def payout_failed(response)
    @payout.payout_failed(response)
  end

  # Callback invoked by processor when payout is pending
  def payout_pending(response)
    @payout.payout_pending(response)
  end

  private

  def new(*args)
  end

end
