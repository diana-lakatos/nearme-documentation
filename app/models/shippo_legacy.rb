# frozen_string_literal: true
module ShippoLegacy
  module Transactable
    extend ActiveSupport::Concern

    included do
      belongs_to :shipping_profile

      # TODO: rental shipping
      def possible_delivery?
        shipping_profile.present?
      end
    end
  end

  module DimensionsTemplate
    def remove_shippo_id
      self.shippo_id = nil
    end

    def get_shippo_id
      shippo_id.presence || create_shippo_parcel[:object_id]
    end

    def create_shippo_parcel
      parcel = instance.shippo_api.create_parcel(to_shippo)
      update_column :shippo_id, parcel[:object_id]
      parcel
    end

    def to_shippo
      {
        length: converted_depth,
        width: converted_width,
        height: converted_height,
        distance_unit: common_distance_unit,
        weight: weight,
        mass_unit: weight_unit
      }
    end
  end

  module Instance
    def self.included(base)
      base.class_eval do
        attr_encrypted :shippo_username, :shippo_password, :shippo_api_token
      end
    end

    def shippo_enabled?
      shippo_api_token.present?
    end

    def shippo_api
      @api ||= ShippoApi::ShippoApi.new(shippo_api_token)
    end
  end

  module OrderAddress
    extend ActiveSupport::Concern

    included do
      # validate :validate_shippo_address, if: -> (address) { address.errors.empty? && shippo_settings_valid? }
    end

    def shippo_settings_valid?
      instance.shippo_api.shippo_api_token_present?
    end

    def validate_shippo_address
      validation = if shippo_id.present?
                     instance.shippo_api.validate_address(shippo_id)
                   else
                     create_shippo_address.validate
                   end
      errors.add(:base, validation.messages.map { |m| m[:text] }.join(' ')) if validation.object_state == 'INVALID'
    end

    def get_shippo_id
      shippo_id.presence || create_shippo_address[:object_id]
    end

    def create_shippo_address
      address = instance.shippo_api.create_address(to_shippo)
      self.shippo_id = address[:object_id]
      address
    end

    def to_shippo
      attribs = attributes
      attribs['country'] = iso_country_code
      attribs['name'] = "#{firstname} #{lastname}"
      attribs['state_name'] = state.name
      attribs['email'] = 'lemkowski@gmail.com'
      attribs['street2'] ||= ''
      attribs['alternative_phone'] ||= ''
      attribs['state'] = iso_state_code || state if iso_country_code.in? %w(US CA)
      attribs.except('id')
    end
  end

  module ShippingOptions
    module ProvidersController
      def update
        if ShippoApi::ShippoApi.verify_connection(instance_params) && @instance.update_attributes(instance_params)
          create_shippo_profiles
          flash[:success] = t('flash_messages.shipping_options.shipping_providers.options_updated')
          redirect_to instance_admin_shipping_options_providers_path
        else
          flash[:error] = t('flash_messages.shipping_options.shipping_providers.options_not_updated')
          render 'edit'
        end
      end

      private

      def create_shippo_profiles
        ShippingProfile.where(shipping_type: 'shippo_one_way', user_id: current_user.id, global: true).first_or_create do |sp|
          sp.name = 'Delivery with Shippo'
          sp.shipping_rules.build(name: 'Pick up', price_cents: 0, processing_time: 0, is_pickup: true)
          sp.shipping_rules.build(name: 'Delivery', price_cents: 0, processing_time: 0, use_shippo_for_price: true)
        end
        ShippingProfile.where(shipping_type: 'shippo_return', user_id: current_user.id, global: true).first_or_create do |sp|
          sp.name = 'Rental with Shippo'
          sp.shipping_rules.build(name: 'Pick up', price_cents: 0, processing_time: 0, is_pickup: true)
          sp.shipping_rules.build(name: 'Delivery & Return', price_cents: 0, processing_time: 0, use_shippo_for_price: true)
        end
      end
    end
  end
end
