class OrderAddress < ActiveRecord::Base
  include Carmen

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :country
  belongs_to :order
  belongs_to :user
  belongs_to :state

  validates :street1, :city, :state, :zip, :country, :phone, :email, presence: true
  validate :country_and_state
  validate :validate_shippo_address, if: -> (address) { address.errors.empty?  && shippo_settings_valid? }

  def full_name
    "#{firstname} #{lastname}"
  end

  def shippo_settings_valid?
    instance.shippo_api.shippo_api_token_present?
  end

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
    errors.add(:state, 'Wrong state name') if iso_country_code.in?(%w(US CA)) && iso_state_code.nil?
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
    attribs['name'] = "#{firstname} #{lastname}"
    attribs['state_name'] = state.name
    attribs['email'] = 'lemkowski@gmail.com'
    attribs['street2'] ||= ''
    attribs['alternative_phone'] ||= ''
    if iso_country_code.in? %w(US CA)
      attribs['state'] = iso_state_code || state
    end
    attribs.except("id")
  end

  def iso_country_code
    country.try(:iso)
  end

  def iso_state_code
    state.try(:abbr)
  end
end
