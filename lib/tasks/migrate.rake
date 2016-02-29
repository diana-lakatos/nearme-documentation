
# Migrate rake task to help with all kind of data migration

namespace :migrate do

  task :create_payment_subscriptions_for_existing_subscriptions => :environment do
    Instance.all.each do |instance|
      instance.set_context!
      next unless RecurringBooking.any?
      puts "Create PaymentSubscription for Instance: #{instance.name} #{instance.id}"

      payment_method = PaymentGateway::StripePaymentGateway.last.payment_methods.credit_card.first

      CreditCard.all.find_each do |card|
        if card.decorator && card.decorator.response.class == ActiveMerchant::Billing::MultiResponse
          card_response = card.decorator.response.responses.select { |r| r.params['object'] == 'card'}.first
          customer_response = card.decorator.response.responses.select { |r| r.params['object'] == 'customer'}.first
          card.response = card_response.to_yaml
          card.save
          if card.instance_client.customer_id != customer_response.params["id"]
            card.instance_client.response = customer_response.to_yaml
            card.save
          end
        end
      end

      RecurringBooking.all.find_each do |recurring_booking|
        next if recurring_booking.payment_subscription.present?
        payment_subscription = recurring_booking.build_payment_subscription(payment_method: payment_method)
        payment_subscription.subscriber = recurring_booking
        payment_subscription.credit_card_id = recurring_booking.credit_card_id
        payment_subscription.save(validate: false)
      end
    end
  end

  task :migrate_current_location_to_current_address do
    Instance.all.each do |instance|
      instance.set_context!
      puts "Address migration for Instance: #{instance.name}"
      i = 0
      User.where.not(current_location: [nil, '']).includes(:current_address).where("addresses.id IS NULL").references(:addresses).limit(2000).find_each do |user|
        sleep(1) if i.modulo(10).zero?
        user.create_current_address(address: user.current_location)
      end
    end
  end

  task :populate_reservation_start_and_end => :environment do
    Reservation.includes(:periods).find_each do |reservation|
      reservation.timezone = reservation.time_zone = reservation.listing.try(:timezone) || Time.zone.name
      reservation.save
    end
  end


  task :country_payment_gateway => :environment do
    class CountryPaymentGateway < ActiveRecord::Base
      auto_set_platform_context
      scoped_to_platform_context

      belongs_to :instance
      belongs_to :payment_gateway

      def country
        Country.find_by_iso(country_alpha2_code)
      end
    end

    PaymentGatewaysCountry.destroy_all
    PaymentGatewaysCurrency.destroy_all

    Instance.all.each do |instance|
      instance.set_context!

      unless PaymentGateway::ManualPaymentGateway.where(instance_id: instance.id).any?
        puts "Creating Offline gateway for Instance: #{instance.name}"
        manual_payment_gateway = PaymentGateway::ManualPaymentGateway.new
        manual_payment_gateway.payment_methods.build(payment_method_type: 'manual', active: instance.possible_manual_payment?, instance_id: instance.id)
        manual_payment_gateway.payment_methods.build(payment_method_type: 'free', active: true, instance_id: instance.id)
        manual_payment_gateway.payment_countries << Country.all
        manual_payment_gateway.payment_currencies << Currency.all
        manual_payment_gateway.test_active = true
        manual_payment_gateway.live_active = true
        manual_payment_gateway.save!
      end

      PaymentGateway.where(instance: instance.id).each do |payment_gateway|
        puts "Building payment methods..."
        payment_gateway.build_payment_methods(true) if payment_gateway.payment_methods.blank?
        payment_gateway.save
      end

      CountryPaymentGateway.where(instance_id: instance.id).each do |cpg|
        payment_gateway = cpg.payment_gateway
        next if payment_gateway.blank?

        unless payment_gateway.payment_countries.include?(cpg.country)
          payment_gateway.payment_countries << cpg.country
        end

        Currency.where(iso_code: payment_gateway.supported_currencies).each do |currency|
          unless payment_gateway.payment_currencies.include?(currency)
            payment_gateway.payment_currencies << currency
          end
        end

        payment_gateway.test_active = true
        payment_gateway.live_active = true
        payment_gateway.save
      end

      puts "Migrating old payment methods..."

      Reservation.where(payment_method_id: nil).where.not(old_payment_method: nil).each do |reservation|
        payment_method = case reservation.old_payment_method
        when 'manual'
          PaymentMethod.where(instance_id: reservation.instance_id).manual.first
        when 'free'
          PaymentMethod.where(instance_id: reservation.instance_id).free.first
        else
          payment_gateways = reservation.instance.payment_gateways(reservation.listing.company.iso_country_code, reservation.currency)
          PaymentMethod.where(payment_method_type: reservation.old_payment_method, payment_gateway_id: payment_gateways.map(&:id)).first
        end

        reservation.update_column(:payment_method_id, payment_method.try(:id))
      end

      Spree::Order.where(payment_method_id: nil).where.not(old_payment_method: nil).each do |order|
        payment_method = case order.old_payment_method
        when 'manual'
          PaymentMethod.where(instance_id: order.instance_id).manual.first
        when 'free'
          PaymentMethod.where(instance_id: order.instance_id).free.first
        else
          payment_gateways = order.instance.payment_gateways(order.seller_iso_country_code, order.currency)
          PaymentMethod.where(payment_method_type: order.old_payment_method, payment_gateway_id: payment_gateways.map(&:id)).first
        end

        order.update_column(:payment_method_id, payment_method.try(:id))
      end
    end

  end
end
