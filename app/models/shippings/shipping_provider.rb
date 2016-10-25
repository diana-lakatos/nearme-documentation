class Shippings::ShippingProvider < ActiveRecord::Base
  include Encryptable

  validates :shipping_provider_name,
            uniqueness: { scope: [:instance_id] }

  belongs_to :instance

  serialize :test_settings, as: Hash
  serialize :live_settings, as: Hash

  attr_encrypted :test_settings, :live_settings, marshal: true

  has_many :dimensions_templates, dependent: :destroy
end
