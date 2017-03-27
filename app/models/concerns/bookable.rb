# frozen_string_literal: true
module Bookable
  extend ActiveSupport::Concern

  included do
    inherits_columns_from_association([:company_id, :creator_id], :transactable)

    attr_accessor :start_minute, :end_minute, :start_on, :end_on, :schedule_params, :total_amount_check,
                  :dates, :force_recalculate_fees, :last_search_json, :dates_fake, :start_time, :booking_type

    has_one :address, class_name: 'Address', as: :entity

    delegate :location, :show_company_name, :transactable_type_id, :transactable_type, to: :transactable
    delegate :action, to: :transactable_pricing

    accepts_nested_attributes_for :address

    validates :quantity, numericality: { greater_than_or_equal_to: 1 } # , less_than_or_equal_to: :transactable_quantity }

    before_validation :set_inheritated_data, on: :create, if: -> { transactable }
    before_validation :set_excusive_quantity, on: :create, if: -> { exclusive_price? }
    before_save :set_start_and_end
    after_create :copy_dimensions_template

    def form_address(last_search_json)
      return address if address.present?
      if last_search_json
        last_search = begin
                        JSON.parse(last_search_json, symbolize_names: true)
                      rescue
                        {}
                      end
        build_address(address: last_search[:loc], longitude: last_search[:lng], latitude: last_search[:lat])
      else
        build_address
      end
    end

    def set_dates_from_search
      if skip_payment_authorization?
        if dates.blank? && start_time.blank?
          self.dates = booking_date_from_search
          self.start_time = booking_time_start_from_search
        end
        self.dates_fake = I18n.l(Date.parse(dates), format: I18n.t('datepicker.dformat'))
      end
    end

    def last_search
      @last_search ||= begin
                         JSON.parse(@last_search_json)
                       rescue
                         {}
                       end
    end

    def booking_date_from_search
      last_search['date'].presence || transactable.first_available_date.to_s
    end

    def booking_time_start_from_search
      last_search['time_from'].presence || 1.hour.from_now.strftime('%k:00').strip
    end

    def assigned_waiver_agreement_templates
      if transactable.try(:assigned_waiver_agreement_templates).try(:any?)
        transactable.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
      elsif transactable.try(:location).try(:assigned_waiver_agreement_templates).try(:any?)
        transactable.location.assigned_waiver_agreement_templates.includes(:waiver_agreement_template).map(&:waiver_agreement_template)
      else (templates = PlatformContext.current.instance.waiver_agreement_templates).any?
           templates
      end
    end

    def add_line_item!(attrs)
      self.attributes = attrs
      self.book_it_out_discount = transactable_pricing.book_it_out_discount if attrs[:book_it_out] == 'true'
      self.reservation_type = transactable.transactable_type.reservation_type
      self.skip_checkout_validation = true
      self.settings = reservation_type.try(:settings)
      save
    end

    def set_excusive_quantity
      self.quantity = transactable.quantity
    end

    def set_start_and_end
      if last_period
        self.starts_at = first_period.starts_at
        self.ends_at = last_period.ends_at
      end
      true
    end

    def date
      first_period.starts_at
    end

    def first_period
      periods.sort_by { |p| [p.starts_at, p.start_minute] }.first
    end

    def last_period
      periods.sort_by { |p| [p.starts_at, p.start_minute] }.last
    end

    def set_inheritated_data
      self.currency ||= transactable.try(:currency)
      self.time_zone ||= transactable.timezone
      self.reservation_type ||= transactable.transactable_type.reservation_type
      self.confirmation_email ||= creator.try(:email)
    end

    def copy_dimensions_template
      return unless transactable.dimensions_template.present?

      Commands::CopyDimensionsTemplate.new(self, transactable.dimensions_template)
    end

    def schedule_expiry
      calc = ExpiryAtTimeCalculator.build(self)

      update_column(:expires_at, calc.expires_at)
      OrderExpiryJob.perform_later(calc.expires_at, id) if calc.should_expire?
    end
  end

  class ExpiryAtTimeCalculator
    class DefaultExpiryAtTimeCalculator
      def initialize(order)
        @order = order
      end

      def expires_at
        Time.current + @order.transactable.hours_to_expiration.to_i.hours
      end

      def should_expire?
        @order.transactable.hours_to_expiration > 0
      end
    end

    class DeliveryBasedExpiryAtTimeCalculator
      def initialize(order)
        @order = order
      end

      # TODO: clarify how this should work
      def should_expire?
        expires_at.present?
      end

      # at this point there should always be at least one date available for pickup
      # so if it fails something wrong is somewhere else but here
      def expires_at
        @order.date.end_of_day
      end
    end

    def self.build(order)
      if Shippings.enabled?(order)
        DeliveryBasedExpiryAtTimeCalculator.new(order)
      else
        DefaultExpiryAtTimeCalculator.new(order)
      end
    end
  end

  module Commands
    class CopyDimensionsTemplate
      def initialize(parent, template)
        @parent = parent
        @template = template
      end

      def perform
        @parent.update_attributes! dimensions_template: copy
      end

      def copy
        @template.dup
      end
    end
  end
end
