# frozen_string_literal: true
module Shippings
  module Instance
    extend ActiveSupport::Concern

    included do |_base|
      has_many :shipping_providers, class_name: 'Shippings::ShippingProvider'
    end
  end
end
