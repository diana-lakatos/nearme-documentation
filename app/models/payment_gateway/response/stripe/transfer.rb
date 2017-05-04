# frozen_string_literal: true
class PaymentGateway::Response::Stripe::Transfer
  delegate :id, :reversed, to: :@response

  def initialize(response)
    @response = response
  end

  def paid?
    if status
      status == 'paid'
    else
      !reversed
    end
  end

  def failed?
    %w(canceled failed).include?(status)
  end

  def status
    @response.try(:status)
  end
end
