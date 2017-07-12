# frozen_string_literal: true
class Payment::Gateway::Response::Stripe::Payout
  delegate :id, to: :@response

  def initialize(response)
    @response = response
  end

  def paid?
    status == 'paid'
  end

  def failed?
    %w(canceled failed).include?(status)
  end

  def status
    @response.try(:status)
  end
end
