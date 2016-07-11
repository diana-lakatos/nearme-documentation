
# Migrate rake task to help with all kind of data migration

namespace :migrate do

  task :update_require_payout => :environment do
    Instance.all.each do |instance|
      instance.set_context!
      MerchantAccount.verified.live.each do |ma|
        ma.set_possible_payout!
      end
    end
  end

  task :create_payment_subscriptions_for_existing_subscriptions => :environment do
    Instance.all.each do |instance|
      instance.set_context!
      if RecurringBooking.any?
        puts "Create PaymentSubscription for Instance: #{instance.name} #{instance.id}"

        stripe = PaymentGateway::StripePaymentGateway.last
        unless stripe.nil?
          payment_method = stripe.payment_methods.credit_card.first

          RecurringBooking.all.find_each do |recurring_booking|
            if recurring_booking.payment_subscription.blank?
              payment_subscription = recurring_booking.build_payment_subscription(payment_method: payment_method)
              payment_subscription.subscriber = recurring_booking
              payment_subscription.credit_card_id = recurring_booking.credit_card_id
              payment_subscription.save(validate: false)
            end
          end
        end
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

  desc 'Migrate to ActionTypes'
  task to_action_types: :environment do
    Instance.where.not(id: 23).find_each do |instance|
      instance.set_context!
      puts "Migrating instance #{instance.id} - #{instance.name}"
      TransactableType.where(type: 'ServiceType').with_deleted.all.each do |tt|
        vars = {}
        puts "Working on TransactableType #{tt.id} - #{tt.name}"
        #schedule booking
        if tt.action_schedule_booking && !tt.event_booking
          action = create_action(tt, 'event_booking', instance)
          action.pricings.new(
            instance: instance,
            number_of_units: 1,
            unit: 'event',
            min_price_cents: tt.min_fixed_price_cents.to_i,
            max_price_cents: tt.max_fixed_price_cents,
            allow_exclusive_price: tt.action_exclusive_price,
            allow_book_it_out_discount: tt.action_book_it_out,
            allow_free_booking: tt.action_free_booking
          )
          action.save!

          Transactable.unscoped.where(instance_id: instance.id, transactable_type_id: tt.id, action_schedule_booking: true, draft: nil).find_each(batch_size: 100) do |t|
            next if t.action_type && t.action_type.pricing
            schedule = Schedule.where(scheduable: t).first
            booking = Transactable::EventBooking.new(
              instance: instance,
              transactable: t,
              transactable_type_action_type: action,
              schedule: schedule,
              minimum_booking_minutes: t.minimum_booking_minutes,
              enabled: true,
              no_action: tt.action_na,
              action_rfq: t.action_rfq
            )
            booking.pricings.new(
              instance: instance,
              transactable_type_pricing: action.pricing,
              number_of_units: 1,
              unit: 'event',
              price_cents: t.fixed_price_cents || 0,
              has_exclusive_price: tt.action_exclusive_price && t.exclusive_price_cents.to_i > 0,
              exclusive_price_cents: t.exclusive_price_cents,
              has_book_it_out_discount: tt.action_book_it_out && t.book_it_out_discount.to_i > 0,
              book_it_out_discount: t.book_it_out_discount,
              book_it_out_minimum_qty: t.book_it_out_minimum_qty,
              is_free_booking: t.action_free_booking
            )
            #TODO: fix schedules and do save!
            booking.save(validate: false)
            if schedule
              new_schedule = booking.build_schedule(schedule.attributes.except('id', 'created_at', 'updated_at').merge({'scheduable_type' => 'Transactable::EventBooking', 'scheduable_id' => booking.id}))
              new_schedule.save(validate: false)
            end
            t.update_column(:action_type_id, booking.id)
            t.reservations.update_all(transactable_pricing_id: booking.pricing.id)
          end
        end
        #time based booking
        if !tt.time_based_booking && (tt.action_hourly_booking || tt.action_overnight_booking || tt.action_daily_booking || tt.action_weekly_booking || tt.action_monthly_booking)
          tt_action = create_action(tt, 'time_based_booking', instance)
          if tt.action_hourly_booking
            hour_tt_pricing = create_pricing_for_tt(tt_action, tt, 'hour', 'hourly', 1, instance)
          end
          if tt.action_overnight_booking && tt.action_daily_booking
            vars[:night_day_tt_pricing] = create_pricing_for_tt(tt_action, tt, 'night', 'daily', 1, instance)
          end
          if tt.action_overnight_booking && tt.action_weekly_booking
            vars[:night_week_tt_pricing] = create_pricing_for_tt(tt_action, tt, 'night', 'weekly', 7, instance)
          end
          if tt.action_overnight_booking && tt.action_monthly_booking
            vars[:night_month_tt_pricing] = create_pricing_for_tt(tt_action, tt, 'night', 'monthly', (tt.days_for_monthly_rate.to_i > 0 ? tt.days_for_monthly_rate.to_i : 30), instance)
          end
          if tt.action_daily_booking || (tt.action_regular_booking && !tt.action_hourly_booking) || tt.action_free_booking
            vars[:day_day_tt_pricing] = create_pricing_for_tt(tt_action, tt, 'day', 'daily', 1, instance)
          end
          if tt.action_weekly_booking
            vars[:day_week_tt_pricing] = create_pricing_for_tt(tt_action, tt, 'day', 'weekly', 7, instance)
          end
          if tt.action_monthly_booking
            vars[:day_month_tt_pricing] = create_pricing_for_tt(tt_action, tt, 'day', 'monthly', (tt.days_for_monthly_rate.to_i > 0 ? tt.days_for_monthly_rate.to_i : 30), instance)
          end

          tt_action.save

          Transactable.unscoped.where(instance_id: instance.id, transactable_type_id: tt.id).where("action_daily_booking = true OR action_hourly_booking = true OR booking_type IN ('regular', 'overnight') AND draft is NULL").find_each(batch_size: 100) do |t|
            next if t.action_type && t.action_type.pricings.any?
            t.location.try(:assign_default_availability_rules) unless t.availability_template

            booking = Transactable::TimeBasedBooking.new(
              instance: instance,
              transactable: t,
              transactable_type_action_type: tt_action,
              minimum_booking_minutes: t.minimum_booking_minutes,
              enabled: true,
              no_action: tt.action_na,
              action_rfq: t.action_rfq,
              availability_template: t.availability_template_id ? (AvailabilityTemplate.find_by(id: t.availability_template_id) || t.location.try(:availability_template)) : t.location.try(:availability_template)
            )

            if hour_tt_pricing && t.action_hourly_booking && t.hourly_price_cents.to_i > 0
              create_pricing_for_t(booking, t, hour_tt_pricing, 'hour', 'hourly', 1, instance)
            end
            if t.action_daily_booking || (%w(overnight regular).include?(t.booking_type))
              unit = t.booking_type == 'overnight' ? 'night' : 'day'
              if vars[:"#{unit}_day_tt_pricing"] && t.daily_price_cents.to_i > 0 || t.action_free_booking
                create_pricing_for_t(booking, t, vars[:"#{unit}_day_tt_pricing"], unit, 'daily', 1, instance)
              end
              if t.weekly_price_cents.to_i > 0
                week_action = tt_action.pricings.where(number_of_units: booking_days_per_week(booking), unit: 'day').first
                create_pricing_for_t(booking, t, week_action, unit, 'weekly', booking_days_per_week(booking), instance)
              end
              if t.monthly_price_cents.to_i > 0
                month_action = tt_action.pricings.where(number_of_units: booking_days_per_month(booking, tt), unit: 'day').first
                create_pricing_for_t(booking, t, month_action, unit, 'monthly', booking_days_per_month(booking, tt), instance)
              end
            end
            booking.save(validate: false)
            t.update_column(:action_type_id, booking.id)
          end
        end
        #subscriptions
        if !tt.subscription_booking && (tt.action_weekly_subscription_booking || tt.action_monthly_subscription_booking)
          tt_action = create_action(tt, 'subscription_booking', instance)
          if tt.action_weekly_subscription_booking
            week_tt_pricing = create_pricing_for_tt(tt_action, tt, 'subscription_day', 'weekly_subscription', 7, instance)
          end
          if tt.action_monthly_subscription_booking
            month_tt_pricing = create_pricing_for_tt(tt_action, tt, 'subscription_month', 'monthly_subscription', 1, instance)
          end

          tt_action.save!

          Transactable.unscoped.where(instance_id: instance.id, transactable_type_id: tt.id).where("weekly_subscription_price_cents > 0 OR monthly_subscription_price_cents > 0 AND draft is NULL").find_each(batch_size: 100) do |t|

            next if t.action_type && t.action_type.pricings.any?
            booking = Transactable::SubscriptionBooking.new(
              instance: instance,
              transactable: t,
              transactable_type_action_type: tt_action,
              enabled: true,
              no_action: tt.action_na,
              action_rfq: t.action_rfq
            )
            if week_tt_pricing && t.weekly_subscription_price_cents.to_i > 0
              create_pricing_for_t(booking, t, week_tt_pricing, 'subscription_day', 'weekly_subscription', 7, instance)
            end
            if month_tt_pricing && t.monthly_subscription_price_cents.to_i > 0
              create_pricing_for_t(booking, t, month_tt_pricing, 'subscription_month', 'monthly_subscription', 1, instance)
            end

            booking.save
            t.update_column(:action_type_id, booking.id)
            if week_tt_pricing && t.weekly_subscription_price_cents.to_i > 0
              t.recurring_bookings.where(interval: 'weekly', transactable_pricing_id: nil).update_all(transactable_pricing_id: booking.pricings.by_unit('subscription_day').first.id)
            end
            if month_tt_pricing && t.monthly_subscription_price_cents.to_i > 0
              t.recurring_bookings.where(interval: 'monthly', transactable_pricing_id: nil).update_all(transactable_pricing_id: booking.pricings.by_unit('subscription_month').first.id)
            end
          end
        end

        #action_na or rfq
        tt_action = create_action(tt, 'no_action_booking', instance)
        if tt.action_free_booking && tt_action.pricings.blank?
          free_tt_pricing = create_pricing_for_tt(tt_action, tt, 'day', 'daily', 1, instance)
        end

        tt_action.save

        Transactable.unscoped.where(instance_id: instance.id, transactable_type_id: tt.id, draft: nil).find_each(batch_size: 100) do |t|
          next if t.action_type
          booking = Transactable::NoActionBooking.create!(
            instance: instance,
            transactable: t,
            transactable_type_action_type: tt_action,
            enabled: true,
            no_action: tt.action_na,
            action_rfq: t.action_rfq
          )
          pricing = create_pricing_for_t(booking, t, free_tt_pricing, 'day', 'daily', 1, instance)
          pricing.is_free_booking = true
          pricing.save!
          t.update_column(:action_type_id, booking.id)
        end
      end
      fix_reservations
    end
  end

  def fix_reservations

    Reservation.where(transactable_pricing_id: nil).find_each(batch_size: 100) do |reservation|
      t = reservation.listing
      unless t
        puts "Skipping reservation #{reservation.id} because nil listing"
        next
      end
      pricing = if t.action_schedule_booking
        t.action_type.pricing
      elsif t.action_type.pricings.one?
        t.action_type.pricings.first
      elsif reservation.booking_type == 'hourly' || (reservation.periods.one? && reservation.periods.first[:start_minute])
        t.action_type.hour_pricings.first
      elsif reservation.booking_type == 'daily' || !reservation.periods.any?{|p| p[:start_minute]}
        if t.action_type.pricings.by_unit(['day', 'night']).one?
          t.action_type.pricings.by_unit(['day', 'night']).first
        else
          unit = t.booking_type == 'overnight' ? 'night' : 'day'
          periods_count = reservation.periods.count
          periods_count -= 1 if unit == 'night'
          t.action_type.pricings.by_unit(unit).where("number_of_units <= ?", periods_count).order('number_of_units DESC').first \
           || t.action_type.pricings.by_unit(unit).order('number_of_units ASC').first
        end
      end
      if pricing.nil?
        unless pricing = t.action_type.pricings.first
          tt_pricing = t.action_type.transactable_type_action_type.pricings.first
          pricing = create_pricing_for_t(t.action_type, t, tt_pricing, tt_pricing.try(:unit) || 'day', 'daily', tt_pricing.try(:number_of_units) || 1, reservation.instance)
          pricing.is_free_booking = true
          pricing.save!
        end
      end
      reservation.update_column(:transactable_pricing_id, pricing.try(:id))
    end
  end

  def booking_days_per_month(action, transactable_type)
    transactable_type.days_for_monthly_rate.to_i.zero? ? booking_days_per_week(action) * 4 : transactable_type.days_for_monthly_rate.to_i
  end

  def booking_days_per_week(action)
    if action.availability
      action.availability.try(:days_open).try(:length) || 7
    else
      action.availability_template = action.transactable.transactable_type.availability_templates.first
      action.availability.try(:days_open).try(:length) || 7
    end
  end

  def create_pricing_for_t(booking, t, tt_pricing, unit, per_unit, number_of_units, instance)
    booking.pricings.new(
      enabled: true,
      instance: instance,
      action: booking,
      transactable_type_pricing: tt_pricing,
      number_of_units: number_of_units,
      unit: unit,
      price_cents: t.send("#{per_unit}_price_cents") || 0,
      has_exclusive_price: false,
      is_free_booking: t.action_free_booking
    )
  end

  def create_pricing_for_tt(tt_action, tt, unit, per_unit, number_of_units, instance)
    tt_action.pricings.new(
      instance: instance,
      number_of_units: number_of_units,
      unit: unit,
      min_price_cents: tt.try("min_#{per_unit}_price_cents").to_i,
      max_price_cents: tt.try("max_#{per_unit}_price_cents"),
      allow_exclusive_price: false,
      allow_book_it_out_discount: false,
      allow_free_booking: tt.action_free_booking
    )
  end

  def create_action(tt, type, instance)
    tt.send(type) || tt.send("build_#{type}",
      tt.slice(
        :cancellation_policy_hours_for_cancellation,
        :cancellation_policy_penalty_percentage,
        :minimum_booking_minutes,
        :action_continuous_dates_booking,
        :hours_to_expiration,
        :cancellation_policy_enabled,
        :cancellation_policy_hours_for_cancellation,
        :cancellation_policy_penalty_percentage,
        :cancellation_policy_penalty_hours,
        :service_fee_guest_percent,
        :service_fee_host_percent,
        :favourable_pricing_rate,
      ).merge({
        instance: instance,
        hours_to_expiration: tt.hours_to_expiration.to_i <= 0 ? 24 : tt.hours_to_expiration.to_i,
        allow_no_action: tt.action_na,
        allow_action_rfq: tt.action_rfq
      })
    )
  end
end
