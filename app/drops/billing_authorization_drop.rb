# frozen_string_literal: true
class BillingAuthorizationDrop < BaseDrop
  # @return [BillingAuthorizationDrop]
  attr_reader :billing_authorization

  # @!method id
  #   @return [Integer] the id of the billing authorization
  delegate :id, to: :billing_authorization

  def initialize(billing_authorization)
    @billing_authorization = billing_authorization
  end
end
