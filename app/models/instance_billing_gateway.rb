class InstanceBillingGateway < ActiveRecord::Base
  belongs_to :instance
  attr_accessible :billing_gateway, :currency

  validates :billing_gateway, :currency, presence: true
end
