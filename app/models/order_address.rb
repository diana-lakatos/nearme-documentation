# frozen_string_literal: true
class OrderAddress < ActiveRecord::Base
  include ShippoLegacy::OrderAddress
  include Carmen

  # TODO: import validation from shipping-provider either
  # to this class or to the delivery class
  # or use external validator ...

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :user
  belongs_to :country
  belongs_to :order
  belongs_to :state

  has_one :address, as: :entity
  accepts_nested_attributes_for :address
  validates :address, presence: true

  delegate :city, :postcode, to: :address, allow_nil: true

  validates :firstname, :lastname, :phone, :email, presence: true

  # TODO: clean up DB table
  # validates :street1, :city, :state, :zip, :country
  # validate :country_and_state
  # def country_and_state
  #   errors.add(:state, 'Wrong state name') if iso_country_code.in?(%w(US CA)) && iso_state_code.nil?
  #   errors.add(:country, 'Wrong country') unless iso_country_code
  # end

  def full_name
    "#{firstname} #{lastname}"
  end

  def iso_country_code
    country.try(:iso)
  end

  def iso_state_code
    state.try(:abbr)
  end
end
