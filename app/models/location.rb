# frozen_string_literal: true
require 'nearest_time_zone'

class Location < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end
  include TransactablesOwnerable
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context

  has_metadata accessors: [:photos_metadata]
  notify_associations_about_column_update([:listings], :administrator_id)
  # notify_associations_about_column_update([:payments, :reservations, :listings], :company_id)
  inherits_columns_from_association([:creator_id], :company)

  include Impressionable
  # Include a set of helpers for handling availability rules and interface onto them
  include AvailabilityRule::TargetHelper

  attr_accessor :search_rank, :transactable_type, :availability_template_attributes

  serialize :address_components, JSON
  serialize :info, Hash

  has_many :assigned_waiver_agreement_templates, as: :target
  has_many :availability_templates, as: :parent
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :impressions, as: :impressionable, dependent: :destroy
  has_many :listings, dependent: :destroy, inverse_of: :location, class_name: 'Transactable'
  has_many :transactables, dependent: :destroy, inverse_of: :location
  has_many :payments, through: :reservations
  has_many :photos, through: :listings
  has_many :reservations, through: :listings
  has_many :wish_list_items, as: :wishlistable
  has_many :waiver_agreement_templates, through: :assigned_waiver_agreement_templates

  has_one :location_address, class_name: 'Address', as: :entity

  belongs_to :company, -> { with_deleted }, inverse_of: :locations
  belongs_to :location_type
  belongs_to :administrator, -> { with_deleted }, class_name: 'User', inverse_of: :administered_locations
  belongs_to :instance
  belongs_to :creator, -> { with_deleted }, class_name: 'User'
  belongs_to :availability_template
  delegate :company_users, :url, to: :company, allow_nil: true
  delegate :phone, to: :creator, allow_nil: true
  delegate :address, :address2, :formatted_address, :postcode, :suburb, :city, :state, :country, :street, :address_components,
           :latitude, :longitude, :state_code, :iso_country_code, :street_number, to: :location_address, allow_nil: true

  validates :company, presence: true
  validates :email, email: true, allow_nil: true
  validates_with CustomValidators

  # We validate the associated availability_template to avoid having locations saved with a blank
  # availability template (when the availability template is invalid with the params the user entered)
  validates_associated :availability_template

  before_validation :build_availability_template, :assign_default_availability_rules, :set_location_type
  before_save :set_time_zone
  after_create :set_external_id
  after_save :update_schedules_timezones
  after_save :update_open_hours, if: 'availability_template_id_changed?'
  after_save :update_location_type, if: :location_type_id_changed?

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history, :finders, :scoped], scope: :instance

  # We do this (:dependent => :delete_all) because:
  # * we want to have acts_as_paranoid out of the equation on the friendly_id_slugs (history table) because
  #   with it, the uniqueness constraints on the table will fail because of lingering records that friendly_id
  #   is not able to find when deciding a slug is available (because it's not using with_deleted)
  # * removing dependent destroy is not an option to just keep records there; it merely results in the
  #   nullification of sluggable_id which makes friendly_id still not able to find
  #   them when looking for existing slugs because it's using a join on location (by sluggable_id);
  #   even if it were not nullified it would probably still not be able to find them because of the join on locations
  #   (which no longer exist)
  # * removing acts_as_paranoid on the friendly_id_slugs is not an option at this point because it's being
  #   added by Spree (!) and messing with it at this point would add even more complications (before we remove Spree)
  # * Using :dependent => :delete_all effectively disables acts_as_paranoid on the friendly_id_slugs table as it just deletes the
  #   records from the database avoiding the acts_as_paranoid overrides
  # * after removing Spree, the proper fix would be to remove acts_as_paranoid on the FriendlyId::Slug
  has_many :slugs, -> { order('friendly_id_slugs.id DESC') },     as: :sluggable,
                                                                  dependent: :delete_all,
                                                                  class_name: 'FriendlyId::Slug'

  scope :filtered_by_location_types_ids, ->(location_types_ids) { where(location_type_id: location_types_ids) }
  scope :no_id, -> { where id: nil }
  scope :near, ->(*args) { all.merge(Address.near(*args).select('locations.*')) }
  scope :bounding_box, ->(box, _midpoint) { all.merge(Address.within_bounding_box(Address.sanitize_bounding_box(box)).select('locations.*')) }
  scope :with_searchable_listings, -> { where(%{ (select count(*) from "transactables" where location_id = locations.id and transactables.draft IS NULL and enabled = 't' and transactables.deleted_at is null) > 0 }) }

  scope :order_by_array_of_ids, lambda  { |location_ids|
    location_ids ||= []
    location_ids_decorated = location_ids.each_with_index.map { |lid, i| "WHEN locations.id=#{lid} THEN #{i}" }
    order("CASE #{location_ids_decorated.join(' ')} END") if location_ids.present?
  }
  # Useful for storing the full geo info for an address, like time zone

  accepts_nested_attributes_for :availability_templates, reject_if: proc { |params| params[:availability_rules_attributes] && params[:availability_rules_attributes].all? { |ar| ar[:open_time].blank? && ar[:close_time] } }

  accepts_nested_attributes_for :listings, :location_address
  accepts_nested_attributes_for :waiver_agreement_templates, allow_destroy: true
  accepts_nested_attributes_for :approval_requests

  def update_open_hours
    days_open = availability.try(:days_open)
    listings.where(availability_template_id: nil).update_all(opened_on_days: days_open)
    listings.where(availability_template_id: nil).pluck(:id).each do |t_id|
      ElasticIndexerJob.perform(:update, 'Transactable', t_id)
    end
    update_column(:opened_on_days, days_open)
  end

  def update_location_type
    ElasticBulkUpdateJob.perform Transactable, listings.searchable.pluck(:id).map { |listing_id| [listing_id, { location_type_id: location_type_id }] }
  end

  def custom_validators
    CustomValidator.where(validatable_type: 'Location')
  end

  def validation_for(field_name)
    custom_validators.detect { |cv| cv.field_name == field_name.to_s }
  end

  def minimum_booking_minutes
    listings.active.map(&:minimum_booking_minutes).compact.max || 60
  end

  def assign_default_availability_rules
    self.availability_template ||= default_availability_template
  end

  def default_availability_template
    listings.first&.default_availability_template || instance.availability_templates.first
  end

  def name
    @name ||= if validation_for(:name)
                self[:name]
              else
                self[:name].presence || [company&.name, street].compact.join(' @ ')
    end
  end

  def admin?(user)
    creator == user
  end

  def description
    self[:description].presence || listings.first.try(:description).presence || ''
  end

  def administrator
    super.presence || creator
  end

  def creator=(creator)
    company.creator = creator
    company.save
  end

  def email
    self[:email].presence || creator.try(:email)
  end

  def phone=(phone)
    creator.phone = phone if creator && creator.phone.blank?
  end

  def to_liquid
    @location_drop ||= LocationDrop.new(self)
  end

  def local_time
    Time.now.in_time_zone(time_zone)
  end

  def self.xml_attributes
    csv_fields.keys
  end

  # @return [Transactable::Pricing] lowest price from among the listings for this location
  def lowest_price(available_price_types = [])
    (listings.loaded? ? listings : listings.searchable).map { |l| l.lowest_price_with_type(available_price_types) }.compact.sort_by(&:price).first
  end

  # @return [Transactable::Pricing] lowest price from amont the listings for this location
  #   including service fees and additional charge types
  def lowest_full_price(available_price_types = [])
    (listings.loaded? ? listings : listings.searchable).map { |l| l.lowest_full_price(available_price_types) }.compact.sort_by(&:price).first
  end

  def approval_request_acceptance_cancelled!
    listings.find_each(&:approval_request_acceptance_cancelled!)
  end

  def approval_request_approved!
    listings.find_each(&:approval_request_approved!)
  end

  def self.csv_fields
    { name: 'Location Name', email: 'Location Email', external_id: 'Location External Id', location_type: 'Location Type', description: 'Location Description', special_notes: 'Location Special Notes' }
  end

  def update_schedules_timezones(force = false)
    if force || time_zone_changed?
      Schedule.where(
        scheduable_type: 'Transactable::EventBooking',
        scheduable_id: listings.map { |l| l.event_booking.try(:id) }.compact
      ).find_each(&:save!)
    end
  end

  def address_to_shippo
    ShippoApi::ShippoFromAddressFillerFromSpree.new(self).to_hash
  end

  def hide_location_availability?
    true
  end

  def custom_availability_template?
    availability_template&.custom_for_location?
  end

  def has_photos?
    photos_metadata.try(:count).to_i > 0
  end

  def time_zone
    super.presence || get_default_timezone
  end

  def jsonapi_serializer_class_name
    'LocationJsonSerializer'
  end

  private

  def company_and_city
    # given company name is My Company and city is San Francisco, generated "my+company-san+francisco"
    if company.try(:name).present? && city.present? && company.name.strip.downcase.include?(city.strip.downcase)
      company.name
    else
      "#{company.try(:name).try(:strip)} #{city}".strip
    end
  end

  def should_generate_new_friendly_id?
    slug.blank? || !slug.starts_with?(company_and_city) || street_changed? || formatted_address_changed?
  end

  def slug_candidates
    [
      :company_and_city,
      [:company_and_city, :street],
      [:company_and_city, :formatted_address],
      [:company_and_city, :formatted_address, self.class.last.try(:id).to_i + 1],
      [:company_and_city, :formatted_address, rand(1_000_000)]
    ]
  end

  def set_external_id
    update_column(:external_id, "manual-#{id}") if external_id.blank?
  end

  def set_location_type
    if transactable_type.try(:skip_location)
      self.location_type ||= instance.location_types.first
      if company.company_address.present? && company.company_address.address.present? && location_address.nil?
        build_location_address(company.company_address.dup.attributes)
        location_address.fetch_coordinates!
      end
    end
  end

  def set_time_zone
    self.time_zone ||= get_default_timezone
  end

  def get_default_timezone
    if latitude && longitude
      tz = NearestTimeZone.to(latitude, longitude)
      ActiveSupport::TimeZone::MAPPING.select { |_k, v| v == tz }.keys.first || 'UTC'
    else
      company.try(:time_zone) || instance.try(:time_zone).presence || 'UTC'
    end
  end

  def build_availability_template
    if availability_template_attributes.present?
      if availability_template_attributes['id'].present? && self.availability_template
        self.availability_template.attributes = availability_template_attributes
        self.availability_template.save
      else
        availability_template_attributes.delete('id')
        availability_template_attributes.merge!(name: 'Custom location availability',
                                                parent: self)
        self.availability_template = AvailabilityTemplate.new(availability_template_attributes)
      end
    end
  end
end
