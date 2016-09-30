# Migrate rake task to help with all kind of data migration

namespace :migrate do

  task :user_avatars => :environment do
    arr = []
    scope = User.with_deleted.where.not(avatar: nil).where('id > ?', 32336)
    count = scope.count
    index = 0
    puts "Migrating production california"
    scope.find_each do |user|
      legacy_path = "s3://near-me-production/instances/universal/uploads/images/user/avatar/#{user.id}"
      new_path = "s3://near-me-production/instances/#{user.instance_id}/uploads/images/user/avatar/#{user.id}"
      cmd = "aws s3 sync #{legacy_path} #{new_path} --acl public-read"
      `#{cmd}`
      index +=1
      if index % 100 == 0
        puts "#{index}/#{count}"
      end
      arr << user.id
    end
    puts "Migrating oregon production"

      legacy_path = "s3://near-me-oregon/instances/universal/uploads/images/user/avatar"
      new_path = "s3://near-me-oregon/instances/132/uploads/images/user/avatar"
      cmd = "aws s3 sync #{legacy_path} #{new_path} --acl public-read"
      puts cmd
      `#{cmd}`

    puts arr.join(', ')
  end

  task rollback_reservations: :environment do
    puts "     ||||||||||||||||||||||||||\n     | Rollback Order Reservation | \n     |||||||||||||||||||||||||| "

    OldReservation.where.not(order_id: nil).each do |old_res|
      Payment.find_by_id(old_res.order_id).update_columns(payable_id: old_res.id, payable_type: "OldReservation")
      Review.find_by_id(old_res.order_id).update_columns(reviewable_id: old_res.id, reviewable_type: "OldReservation")
      WaiverAgreement.find_by_id(old_res.order_id).update_columns(target_id: old_res.id, target_type: "OldReservation")
      Attachable::PaymentDocument.find_by_id(old_res.order_id).update_columns(attachable_id: old_res.id, attachable_type: "OldReservation")
      UserMessage.find_by_id(old_res.order_id).update_columns(thread_context_id: old_res.id, thread_context_type: "OldReservation")
      AdditionalCharge.find_by_id(old_res.order_id).update_columns(target_id: old_res.id, target_type: "OldReservation")
    end

    Payment.where(payable_type: "OldReservation").update_all(payable_type: "Reservation")
    Review.where(reviewable_type: "OldReservation").update_all(reviewable_type: "Reservation")
    WaiverAgreement.where(target_type: "OldReservation").update_all(target_type: "Reservation")
    Attachable::PaymentDocument.where(attachable_type: "OldReservation").update_all(attachable_type: "Reservation")
    UserMessage.where(thread_context_type: "OldReservation").update_all(thread_context_type: "Reservation")
    AdditionalCharge.where(target_type: "OldReservation").update_all(target_type: "Reservation")
  end

  task :update_require_payout => :environment do
    Instance.all.each do |instance|
      instance.set_context!
      MerchantAccount.verified.live.each do |ma|
        ma.set_possible_payout!
      end
    end
  end

  task :checkout_to_form_components => :environment do
    Instance.where.not(id: 23).find_each do |instance|
      next if instance.is_community?
      instance.set_context!
      puts "processing #{instance.name}"

      instance.transactable_types.each do |tt|
        if tt.reservation_type.present?
          reservation_type = tt.reservation_type
          form_component = reservation_type.form_components.first_or_create(name: "Review", form_type: 'reservation_attributes')

          InstanceProfileType.buyer.each do |ipt|
            CustomAttributes::CustomAttribute.get_from_cache(ipt, "InstanceProfileType").each do |ca|
              ca_name = ca[0]

              unless form_component.form_fields.select {|a| a ==  {"buyer" => ca_name}}.any?
                form_component.form_fields.insert(0, {"buyer" => ca_name})
              end
            end
          end

          unless form_component.form_fields.select {|a| a ==  {"reservation" => 'payments'}}.any?
            form_component.form_fields << {"reservation" => "payments"}
          end

        else
          reservation_type = tt.build_reservation_type({
            transactable_types: [tt],
            name: tt.name + ' checkout'
          })
          reservation_type.save(validate: false)
          Utils::FormComponentsCreator.new(reservation_type).create!
          form_component = reservation_type.reload.form_components.first

          InstanceProfileType.buyer.each do |ipt|
            CustomAttributes::CustomAttribute.get_from_cache(ipt, "InstanceProfileType").each do |ca|
              ca_name = ca[0]

              unless form_component.form_fields.select {|a| a ==  {"buyer" => ca_name}}.any?
                form_component.form_fields.insert(0, {"buyer" => ca_name})
              end
            end
          end
          form_component.form_fields = [{"reservation" => "payments"}]
        end

        form_component.save!
      end
    end
  end

  task clean_after_spree_removal: :environment do
    migrated_classes = ["Spree::Order", "OldReservation", "OldRecurringBookingPeriod"]
    Payment.where(payable_type: migrated_classes).destroy_all
    Review.where(reviewable_type: migrated_classes).destroy_all
    WaiverAgreement.where(target_type: migrated_classes).destroy_all
    Attachable::PaymentDocument.where(attachable_type: migrated_classes).destroy_all
    UserMessage.where(thread_context_type: migrated_classes).destroy_all
  end

  task spree_orders_to_orders: :environment do
    puts "     ||||||||||||||||||||||||||\n     | Migrating Spree::Order | \n     |||||||||||||||||||||||||| "

    class WorkflowAlert < ActiveRecord::Base
      class Invoker
        def invoke!(step)
          puts "WorkflowAlert silenced\n"
        end
      end
    end

    Instance.all.each do |instance|
      instance.set_context!
      old_orders = Spree::Order.where(order_id: nil).where(instance_id: instance.id)
      next unless old_orders.any?
      puts "\n----- Processing Instance: #{PlatformContext.current.instance.name}: #{old_orders.count} orders "

      old_orders.find_each do |old_order|
        if old_order.payment.nil? || old_order.payment.pending?
          puts "- F - Skipping [ Spree::Order.find(#{old_order.id}) ]. Missing payment"
          next
        end


        purchase = Purchase.new(common_attributes(old_order, Purchase.new))

        purchase.state = {
          "complete" => "confirm",
          "address" => 'inactive',
          "delivery" => 'inactive',
          "payment" => 'inactive',
          "cart" => 'inactive',
          "canceled" => 'cancelled_by_host',
          }[old_order.state]

        old_order.line_items.each do |old_line_item|
          transactable = old_line_item.variant.product.try(:transactable)
          if transactable
            purchase.transactable_line_items.build({
              line_itemable: purchase,
              transactable_pricing_id: transactable.action_type.pricing,
              name: transactable.name,
              quantity: old_line_item.quantity,
              receiver: "host",
              line_item_source: transactable,
              unit_price: old_line_item.price,
              service_fee_guest_percent: old_order.service_fee_guest_percent,
              service_fee_host_percent: old_order.service_fee_host_percent,
            })

            if purchase.save
              old_order.update_column(:order_id, purchase.id)
              old_order.payment.update_attribute(:payable, purchase)
              old_order.reviews.each { |um| um.update_attribute(reviewable: purchase) }
              old_order.payment_documents.each { |um| um.update_attribute(:attachable, purchase) }

              if old_order.ship_address
                purchase.create_shipping_address(common_attributes(old_order.ship_address, OrderAddress.new).merge({
                  street1: old_order.ship_address.address1,
                  street2: old_order.ship_address.address2,
                  zip: old_order.ship_address.zipcode,
                  email: purchase.user.email,
                  state: State.find_by_name(old_order.ship_address.state.name),
                  country_id:  Country.find_by_name(old_order.ship_address.country.name),
                  instance_id: purchase.instance_id,
                  user_id: purchase.user_id,
                  shippo_id: nil
                }))
              end
              if old_order.bill_address
                purchase.create_billing_address(common_attributes(old_order.bill_address, OrderAddress.new).merge({
                  street1: old_order.ship_address.address1,
                  street2: old_order.ship_address.address2,
                  zip: old_order.ship_address.zipcode,
                  email: purchase.user.email,
                  state: State.find_by_name(old_order.ship_address.state.name),
                  country_id:  Country.find_by_name(old_order.ship_address.country.name),
                  instance_id: purchase.instance_id,
                  user_id: purchase.user_id,
                  shippo_id: nil
                }))
              end

              old_order.additional_charges.each do |ac|
                purchase.additional_line_items.create(
                  line_itemable: purchase,
                  line_item_source: ac.additional_charge_type,
                  optional: ac.optional?,
                  receiver: ac.commission_receiver,
                  name: ac.name,
                  quantity: 1,
                  unit_price_cents: ac.amount_cents
                )
              end

              purchase.transactable_line_items.each do |transactable_line_item|
                if old_order.shipments.any?
                  osm = old_order.shipments.first.selected_shipping_rate.try(:shipping_method)
                  if osm
                    osm_price = osm.calculator.try(:preferred_amount).to_i <= TransactableType::Pricing::MAX_PRICE ? osm.calculator.try(:preferred_amount).to_i : 0
                    shipping_rate = transactable_line_item.transactable.shipping_profile.try { |sp| sp.shipping_rules.where(price: osm_price, name: osm.name) }
                    if shipping_rate
                      shipment = purchase.shipments.build(
                        shipping_rate: shipping_rate,
                        shippo_rate_id: osm.shippo_rate_id,
                        tracking_number: osm.shippo_label_url,
                        label_url: osm.shippo_tracking_number,
                        insurance_value: osm.insurance_amount,
                        insurance_currency: osm.insurance_currency,
                        name: osm.name
                      )
                      shipment.save(validate: false) # to skip before validation callback
                    end
                  end
                end

                puts ("- S - SAVED! \n")
              end

              # Price check controll

              if old_order.total_amount_cents.to_i != purchase.total_amount_cents.to_i
                puts "- E - Wrong total amount for Purchase #{purchase.id} - #{old_order.total_amount_cents.to_i} vs #{purchase.total_amount_cents.to_i}"
              end

              if purchase.payment.total_amount_cents.to_i != purchase.total_amount_cents.to_i
                puts "- E - total_amount_cents for Payment and Purchase (#{purchase.id}) differs "
              end
            end
          else
            puts "- F - Skipping [ Spree::LineItem.find(#{old_line_item.id}) ]. Missing Transactable. \n"
          end
        end
      end
    end
  end

  task :reservations_to_orders => :environment do
    puts "     ||||||||||||||||||||||||||\n     | Migrating Reservations | \n     |||||||||||||||||||||||||| "

    @deprecated_admin_ids = [2807,2854,7500,4374,5073,3528,7952,7501]

    class Reservation < Order
      # We don't want to validate old Reservations
      def validate_order_for_action
      end
      # We don't want this to perform
      def pre_booking_job
      end
    end

    class WorkflowAlert < ActiveRecord::Base
      class Invoker
        def invoke!(step)
          puts "WorkflowAlert silenced\n"
        end
      end
    end

    Instance.all.each do |instance|
      next if [103].include? instance.id
      instance.set_context!

      old_reservations = OldReservation.not_migrated.where.not(transactable_pricing: nil).
        where(instance_id: instance.id).where.not(owner_id: @deprecated_admin_ids).
        where.not(creator_id: @deprecated_admin_ids).where.not(transactable_pricing_id: nil)

      next unless old_reservations.any?
      puts "\n Processing Instance: #{PlatformContext.current.instance.name} - #{old_reservations.count} old reservaions for "

      old_reservations.find_each do |old_reservation|

        if old_reservation.transactable_pricing.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, transactable_pricing is missing \n"
          next
        elsif old_reservation.transactable_pricing.action.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, transactable_pricing is missing action \n"
          next
        elsif old_reservation.transactable_pricing.transactable.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, transactable for transactable_pricing is missing \n"
          next
        elsif old_reservation.transactable.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, transactable is missing \n"
          next
        elsif old_reservation.action.class == Transactable::NoActionBooking
          # puts "- F - Skipping old reservation #{old_reservation.id}, transactable has no action \n"
          next
        elsif @deprecated_admin_ids.include?(old_reservation.owner_id) || @deprecated_admin_ids.include?(old_reservation.creator_id)
          next # skip old admins
        elsif old_reservation.creator.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, creator (#{User.unscoped.find_by_id(old_reservation.creator_id).try(:name)} - #{old_reservation.creator_id}) is missing (removed or deprecated admin) \n"
          next
        elsif old_reservation.owner.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, owner (#{User.unscoped.find_by_id(old_reservation.owner_id).try(:name)} - #{old_reservation.owner_id}) is missing (removed or deprecated admin) \n"
          next
        elsif old_reservation.payment.nil?
          puts "- F - Skipping old reservation #{old_reservation.id}, payment is missing \n"
          next
        end

        if old_reservation.payment.total_amount_cents.to_i != old_reservation.total_amount_cents.to_i
          puts "Reservation.find(#{old_reservation.id}).total_amount_cents == Reservation.find(#{old_reservation.id}).payment.total_amount_cents"
          puts "OldReservation.find(#{old_reservation.id}).total_amount_cents == OldReservation.find(#{old_reservation.id}).payment.total_amount_cents"
        end

        reservation = Reservation.new(common_attributes(old_reservation, Reservation.new))
        reservation.user = User.unscoped.find_by_id(old_reservation.owner_id)
        transactable = old_reservation.transactable

        reservation.transactable_line_items.build({
          line_itemable: reservation,
          name: transactable.name,
          quantity: old_reservation.quantity,
          receiver: "host",
          line_item_source: transactable,
          unit_price_cents: old_reservation.subtotal_amount_cents / old_reservation.quantity,
          service_fee_guest_percent: old_reservation.subtotal_amount_cents.to_f.zero? ? 0 : old_reservation.service_fee_amount_guest_cents.to_f / old_reservation.subtotal_amount_cents.to_f * 100,
          service_fee_host_percent: old_reservation.subtotal_amount_cents.to_f.zero? ? 0 :  old_reservation.service_fee_amount_host_cents.to_f / old_reservation.subtotal_amount_cents.to_f * 100,
        })

        reservation.periods = old_reservation.periods

        if reservation.save
          old_reservation.update_column(:order_id, reservation.id)
          payment = old_reservation.payment
          payment.update_attributes(payable_type: "Reservation", payable_id: reservation.id)
          old_reservation.reviews.each { |um| um.update_columns(reviewable_id: reservation.id, reviewable_type: "Reservation") }
          old_reservation.waiver_agreements.each { |um| um.update_attributes(target_id: reservation.id, target_type: "Reservation") }
          old_reservation.payment_documents.each { |um| um.update_attributes(attachable_id: reservation.id, attachable_type: "Reservation") }
          old_reservation.shipments.each { |um| um.update_attribute(:order_id, reservation.id) }
          old_reservation.user_messages.each { |um| um.update_attributes(thread_context_id: reservation.id, thread_context_type: "Reservation") }

          old_reservation.additional_charges.each do |ac|
            reservation.additional_line_items.create(
              line_itemable: reservation,
              line_item_source: ac.additional_charge_type,
              optional: ac.optional?,
              receiver: ac.commission_receiver,
              name: ac.name,
              quantity: 1,
              unit_price_cents: ac.amount_cents
            )
          end

           # Price check controll

          if old_reservation.total_amount_cents.to_i != reservation.total_amount_cents.to_i || old_reservation.subtotal_amount_cents.to_i != reservation.subtotal_amount_cents.to_i
            puts "- E - Wrong total amount for [ Reservation.find(#{reservation.id}) ]"
            puts "--------------| Old ----- New ]"
            puts "---- total ---| #{old_reservation.total_amount_cents.to_i} ----- #{reservation.total_amount_cents.to_i}"
            puts "---- subtotal-| #{old_reservation.subtotal_amount_cents.to_i} ----- #{reservation.subtotal_amount_cents.to_i}"
            puts "--- fee guest-| #{old_reservation.service_fee_amount_guest_cents.to_i} ----- #{reservation.service_fee_amount_guest_cents.to_i}"
            puts "--- fee host--| #{old_reservation.service_fee_amount_host_cents.to_i} ----- #{reservation.service_fee_amount_host_cents.to_i}"
            puts "---fee guest%-| #{old_reservation.service_fee_guest_percent.to_i}% ----- #{reservation.service_fee_guest_percent.to_i}%"
            puts "---fee host%-| #{old_reservation.service_fee_host_percent.to_i}% ----- #{reservation.service_fee_host_percent.to_i}%"
          elsif payment.total_amount_cents.to_i != reservation.total_amount_cents.to_i
            puts "- E - Wrong payment total amount for [ Reservation.find(#{reservation.id}) ]"
            puts "-- #{ payment.test_mode? ? 'TEST' : ''}"
            puts "--------------| Old ----- New ]"
            puts "---- payment--| #{payment.total_amount_cents.to_i}"
            puts "---- total ---| #{old_reservation.total_amount_cents.to_i} ----- #{reservation.total_amount_cents.to_i}"
            puts "---- subtotal-| #{old_reservation.subtotal_amount_cents.to_i} ----- #{reservation.subtotal_amount_cents.to_i}"
            puts "--- fee guest-| #{old_reservation.service_fee_amount_guest_cents.to_i} ----- #{reservation.service_fee_amount_guest_cents.to_i}"
            puts "--- fee host--| #{old_reservation.service_fee_amount_host_cents.to_i} ----- #{reservation.service_fee_amount_host_cents.to_i}"
            puts "---fee guest%-| #{old_reservation.service_fee_guest_percent.to_i}% ----- #{reservation.service_fee_guest_percent.to_i}%"
            puts "---fee host%-| #{old_reservation.service_fee_host_percent.to_i}% ----- #{reservation.service_fee_host_percent.to_i}%"
          else
            $stdout.flush
            print "."
          end
        else
          print "- E - " + reservation.errors.full_messages.to_s + " [ OldReservation.find(#{old_reservation.id})] \n"
        end
      end
    end
  end

  task :recurring_booking_to_orders => :environment do

    puts "Migrating RecurringBooking: "
    @deprecated_admin_ids = [2807,2854,7500,4374,5073,3528,7952,7501]

    class WorkflowAlert < ActiveRecord::Base
      class Invoker
        def invoke!(step)
          puts "WorkflowAlert silenced\n"
        end
      end
    end

    Instance.all.each do |instance|
      instance.set_context!
      old_recurring_booking = OldRecurringBooking.not_migrated.where(instance_id: instance.id).where.not(transactable_pricing_id: nil)
      next unless old_recurring_booking.any?
      puts "#{old_recurring_booking.count} old reservaions for Instance: #{PlatformContext.current.instance.name}"

      old_recurring_booking.find_each do |old_recurring_booking|

        if old_recurring_booking.transactable_pricing.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, transactable_pricing is missing \n"
          next
        elsif old_recurring_booking.transactable_pricing.action.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, transactable_pricing is missing action \n"
          next
        elsif old_recurring_booking.transactable_pricing.transactable.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, transactable for transactable_pricing is missing \n"
          next
        elsif old_recurring_booking.transactable.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, transactable is missing \n"
          next
        elsif old_recurring_booking.action.class == Transactable::NoActionBooking
          # puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, transactable has no action \n"
          next
        elsif @deprecated_admin_ids.include?(old_recurring_booking.owner_id) || @deprecated_admin_ids.include?(old_recurring_booking.creator_id)
          next # skip old admins
        elsif old_recurring_booking.creator.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, creator (#{User.unscoped.find_by_id(old_recurring_booking.creator_id).try(:name)} - #{old_recurring_booking.creator_id}) is missing (removed or deprecated admin) \n"
          next
        elsif old_recurring_booking.owner.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, owner (#{User.unscoped.find_by_id(old_recurring_booking.owner_id).try(:name)} - #{old_recurring_booking.owner_id}) is missing (removed or deprecated admin) \n"
          next
        elsif old_recurring_booking.payment_subscription.nil?
          puts "- F - Skipping old recurring booking #{old_recurring_booking.id}, payment subscription is missing \n"
          next
        end

        recurring_booking = RecurringBooking.new(common_attributes(old_recurring_booking, RecurringBooking.new))
        transactable = old_recurring_booking.listing
        recurring_booking.user = old_recurring_booking.owner
        recurring_booking.transactable = transactable

        transactable_line_item = recurring_booking.transactable_line_items.build({
          line_itemable: recurring_booking,
          name: transactable.name,
          quantity: old_recurring_booking.quantity,
          receiver: "host",
          line_item_source: transactable,
          unit_price_cents: old_recurring_booking.subtotal_amount_cents / old_recurring_booking.quantity,
          service_fee_guest_percent: (old_recurring_booking.subtotal_amount_cents.to_f.zero? ? 0 : old_recurring_booking.service_fee_amount_guest_cents.to_f / old_recurring_booking.subtotal_amount_cents.to_f * 100).round(1),
          service_fee_host_percent: (old_recurring_booking.subtotal_amount_cents.to_f.zero? ? 0 :  old_recurring_booking.service_fee_amount_host_cents.to_f / old_recurring_booking.subtotal_amount_cents.to_f * 100).round(1),
        })

        if recurring_booking.service_fee_amount_guest_cents != old_recurring_booking.service_fee_amount_guest_cents && recurring_booking.service_fee_line_items.present?
          recurring_booking.service_fee_line_items.first.unit_price_cents = old_recurring_booking.service_fee_amount_guest_cents
        end

        if recurring_booking.save
          recurring_booking.update_attributes({
            starts_at: old_recurring_booking.start_on,
            ends_at: old_recurring_booking.end_on,
            next_charge_date: old_recurring_booking.next_charge_date
          })

          old_recurring_booking.update_column(:order_id, recurring_booking.id)
          old_recurring_booking.payment_subscription.update_attribute(:subscriber, recurring_booking)
          old_recurring_booking.user_messages.each { |um| um.update_attribute(:thread_context, recurring_booking) }
          old_recurring_booking.old_recurring_booking_periods.each do |orbp|
            rbp = recurring_booking.recurring_booking_periods.build(orbp.attributes.except("id", "recurring_booking_id"))

            rbp.transactable_line_items.build({
              line_itemable: rbp,
              name: transactable.name,
              quantity: old_recurring_booking.quantity,
              line_item_source: transactable,
              unit_price_cents: orbp.subtotal_amount_cents / old_recurring_booking.quantity,
              service_fee_guest_percent: transactable_line_item.service_fee_guest_percent,
              service_fee_host_percent:  transactable_line_item.service_fee_host_percent
            })

            if rbp.save
              orbp.payment.update_attribute(:payable, rbp) if orbp.payment

              if rbp.service_fee_amount_guest_cents != orbp.service_fee_amount_guest_cents &&  rbp.service_fee_line_items.first.present?
                rbp.service_fee_line_items.first.update_attributes(unit_price_cents: orbp.service_fee_amount_guest_cents)
              end

              if orbp.total_amount_cents.to_i != rbp.total_amount_cents.to_i || orbp.subtotal_amount_cents.to_i != rbp.subtotal_amount_cents.to_i
                puts "- E - Wrong total amount for [ RecurribgBooking.find(#{rbp.id}) ]"
                puts "--------------| Old ----- New ]"
                puts "---- total ---| #{orbp.total_amount_cents.to_i} ----- #{rbp.total_amount_cents.to_i}"
                puts "---- subtotal-| #{orbp.subtotal_amount_cents.to_i} ----- #{rbp.subtotal_amount_cents.to_i}"
                puts "--- fee guest-| #{orbp.service_fee_amount_guest_cents.to_i} ----- #{rbp.service_fee_amount_guest_cents.to_i}"
                puts "--- fee host--| #{orbp.service_fee_amount_host_cents.to_i} ----- #{rbp.service_fee_amount_host_cents.to_i}"
                puts "---fee guest%-| #{orbp.service_fee_guest_percent}% ----- #{rbp.service_fee_guest_percent}%"
                puts "---fee host%-| #{orbp.service_fee_host_percent}% ----- #{rbp.service_fee_host_percent}%"
              end
            else
              puts "Can not process OldRecurringBookingPeriod id #{orbp.id}"
            end
          end

          if old_recurring_booking.total_amount_cents.to_i != recurring_booking.total_amount_cents.to_i || old_recurring_booking.subtotal_amount_cents.to_i != recurring_booking.subtotal_amount_cents.to_i
            puts "- E - Wrong total amount for [ RecurribgBooking.find(#{recurring_booking.id}) ]"
            puts "--------------| Old ----- New ]"
            puts "---- total ---| #{old_recurring_booking.total_amount_cents.to_i} ----- #{recurring_booking.total_amount_cents.to_i}"
            puts "---- subtotal-| #{old_recurring_booking.subtotal_amount_cents.to_i} ----- #{recurring_booking.subtotal_amount_cents.to_i}"
            puts "--- fee guest-| #{old_recurring_booking.service_fee_amount_guest_cents.to_i} ----- #{recurring_booking.service_fee_amount_guest_cents.to_i}"
            puts "--- fee host--| #{old_recurring_booking.service_fee_amount_host_cents.to_i} ----- #{recurring_booking.service_fee_amount_host_cents.to_i}"
            puts "---fee guest%-| #{old_recurring_booking.service_fee_guest_percent}% ----- #{recurring_booking.service_fee_guest_percent}%"
            puts "---fee host%-| #{old_recurring_booking.service_fee_host_percent}% ----- #{recurring_booking.service_fee_host_percent}%"
          else
            $stdout.flush
            print "."
          end
        else
          print "#"
          print reservation.errors.full_messages
        end
      end
    end
    puts "Finito!"
  end

  #############################################################################################################

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
      reservation.timezone = reservation.time_zone = reservation.transactable.try(:timezone) || Time.zone.name
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
          payment_gateways = reservation.instance.payment_gateways(reservation.transactable.company.iso_country_code, reservation.currency)
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
    Instance.find_each do |instance|
      next if instance.is_community?
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
        enabled: true,
        hours_to_expiration: tt.hours_to_expiration.to_i <= 0 ? 24 : tt.hours_to_expiration.to_i,
        allow_no_action: tt.action_na,
        allow_action_rfq: tt.action_rfq
      })
    )
  end

  def common_attributes(new_object, old_object)
    new_object.attributes.select { |key, value|
      ![:id, :type].include?(key.to_sym) && (new_object.attributes.keys & old_object.attributes.keys).include?(key)
    }
  end
end
