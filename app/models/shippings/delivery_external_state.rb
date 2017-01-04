class Shippings::DeliveryExternalState < ActiveRecord::Base
  acts_as_paranoid
  scoped_to_platform_context
  auto_set_platform_context

  serialize :body, Hash

  belongs_to :delivery

  delegate :state, :order_id, :tracking_url, :labels, to: :details

  private

  # adapter for shipping-provider based response
  def details
    @details ||= StateDetails.new(body)
  end

  # this one is just a generic simple one
  # for furure providers prepare new classes
  class StateDetails < Hashie::Mash
  end
end
