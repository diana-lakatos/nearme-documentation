class BillingAuthorizationDrop < BaseDrop
  attr_reader :billing_authorization

  delegate :id, to: :billing_authorization

  def initialize(billing_authorization)
    @billing_authorization = billing_authorization
  end
end
