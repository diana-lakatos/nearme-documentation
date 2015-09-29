class ShippingAddress < ActiveRecord::Base
  include Carmen

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance

  validates :street1, :city, :state, :zip, :name, :country, :phone, :email, presence: true
  validate :country_and_state
  validate :validate_shippo_address, if: -> (address) { address.errors.empty? }


  def validate_shippo_address
    validation = if self.shippo_id.present?
      instance.shippo_api.validate_address(self.shippo_id)
    else
      create_shippo_address.validate
    end
    if validation.object_state == 'INVALID'
      errors.add(:base, validation.messages.map{|m| m[:text]}.join(' '))
    end
  end

  def country_and_state
    errors.add(:state, 'Wrong state name') unless iso_state_code
    errors.add(:country, 'Wrong country') unless iso_country_code
  end

  def get_shippo_id
    self.shippo_id.presence || create_shippo_address[:object_id]
  end

  def create_shippo_address
    address = instance.shippo_api.create_address(to_shippo)
    self.shippo_id = address[:object_id]
    address
  end

  def to_shippo
    attribs = self.attributes
    attribs['country'] = iso_country_code
    if iso_country_code.in? %w(US CA)
      attribs['state'] = iso_state_code || state
    end
    attribs
  end

  def iso_country_code
    iso_country.try(:code)
  end

  def iso_state_code
    subregion = iso_country.subregions.named(state) || iso_country.subregions.coded(state)
    subregion.try(:code)
  end

  def iso_country
    @iso_country ||= Country.named(country)
  end

end
