# frozen_string_literal: true
class Shippings::ShippingProvider < ActiveRecord::Base
  include Encryptable

  validates :shipping_provider_name, uniqueness: { scope: [:instance_id] }
  validates_with Shippings::ProviderSettingsValidator, on: :update

  belongs_to :instance

  serialize :settings, as: Hash

  attr_encrypted :settings, marshal: true

  has_many :dimensions_templates, dependent: :restrict_with_error

  def environment
    settings && settings['environment']
  end
end
