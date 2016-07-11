namespace :fix do
  task :payments_payer => [:environment] do
    Instance.find_each do |i|
      puts "Processing #{i.name}"
      i.set_context!
      Payment.find_each do |p|
        p.update_column(:payer_id, p.payable.owner.id)
      end
    end
  end

  desc "fixes domain for local use after db rebuild"
  task :domains_on_local => [:environment] do
    if Rails.env.development?
      Domain.where("name ilike '%near-me.com%'").find_each do |domain|
        puts "Fixing #{domain.name}"
        domain.update_column :name, domain.name.gsub('near-me.com', 'lvh.me')
      end
      Domain.where(name: 'desksnear.lvh.me', use_as_default: true, target: Instance.first, instance: Instance.first).first_or_create!
    end
  end

  desc "Fix first period pro-rata"
  task :first_period_pro_rata => [:environment] do
    Instance.find(130).set_context!
    rbs = RecurringBooking.all.select { |rb| rb.total_amount_cents == rb.recurring_booking_periods.try(:first).try(:total_amount_cents) && rb.start_on.day != 1 }
    rbs.each do |rb|
      period = rb.recurring_booking_periods.first
      p = period.payments.first
      if period.paid_at.present?
        puts "WARNING WARNING WARNING WARNING - PERIOD #{period.id} HAS BEEN ALREADY PAID!!!!!!!!!!"
      elsif p.paid?
        puts "WARNING WARNING WARNING WARNING - PAYMENT #{p.id} HAS BEEN ALREADY PAID!!!!!!!!!!"
      else
        puts "Processing rb #{rb.id}"
        puts "\trb amounts: subtotal: #{rb.subtotal_amount_cents}, guest fee: #{rb.service_fee_amount_guest_cents}"
        puts "\tPeriod details: from: #{period.period_start_date} - #{period.period_end_date}"
        puts "\tPeriod #{period.id} amounts "
        puts "\t\tbefore change: #{period.subtotal_amount_cents}, guest fee: #{period.service_fee_amount_guest_cents}, host fee: #{period.service_fee_amount_host_cents}"
        pro_rata = (rb.start_on.end_of_month.day - rb.start_on.day + 1) / rb.start_on.end_of_month.day.to_f
        period.subtotal_amount = Money.new((rb.subtotal_amount.cents * pro_rata).ceil, rb.currency)
        period.service_fee_amount_guest = Money.new((rb.service_fee_amount_guest.cents * pro_rata).ceil, rb.currency)
        period.service_fee_amount_host = Money.new((rb.service_fee_amount_host.cents * pro_rata).ceil, rb.currency)
        puts "\t\tafter change: #{period.subtotal_amount_cents}, guest fee: #{period.service_fee_amount_guest_cents}, host fee: #{period.service_fee_amount_host_cents}"
        period.save!
        if p.present?
          puts "\tPayment #{p.id} amounts "
          puts "\t\tbefore change: #{p.subtotal_amount_cents}, guest fee: #{p.service_fee_amount_guest_cents}, host fee: #{p.service_fee_amount_host_cents}"
          p.subtotal_amount = Money.new((rb.subtotal_amount.cents * pro_rata).ceil, rb.currency)
          p.service_fee_amount_guest = Money.new((rb.service_fee_amount_guest.cents * pro_rata).ceil, rb.currency)
          p.service_fee_amount_host = Money.new((rb.service_fee_amount_host.cents * pro_rata).ceil, rb.currency)
          puts "\t\tafter change: #{p.subtotal_amount_cents}, guest fee: #{p.service_fee_amount_guest_cents}, host fee: #{p.service_fee_amount_host_cents}"
          p.save!
          p.capture
          if p.paid?
            puts "\t\tSuccessfully captured payment!"
            period.update_attribute(:paid_at, Time.zone.now)
            # if we end up doing something in wrong order, we want to have the maximum period_end_date which was paid.
            # so if we pay for December, November and October, we want paid_until to be 31st of December
            rb.update_attribute(:paid_until, period.period_end_date) unless rb.paid_until.present? && rb.paid_until > period.period_end_date
          else
            puts "\t\tEPIC FAIL - CAPTURE FAILED"
            rb.overdue
          end
        else
          puts "\t\tNo payment"
        end
      end
    end && nil
  end

  desc "Fix buy_sell"
  task :buy_sell_count_on_hand => [:environment] do
    Instance.find_each do |i|
      i.set_context!
      if i.product_types.count.zero?
        puts "Skipping #{i.name}(id=#{i.id})"
        next
      else
        puts "Processing #{i.name}(id=#{i.id})"
      end
      Spree::Variant.find_each do |v|
        if(stock_items = v.stock_items.where('count_on_hand > 0')).size > 1
          puts "\tVariant #{v.id} has #{stock_items.size} stock items with count_on_hand > 0"
          stock_items.first(stock_items.size-1).each do |st|
            puts "\t\tUpdating stock item #{st.id} to change count from #{st.count_on_hand} to 0"
            st.update_attribute(:count_on_hand, 0)
          end
        end
      end
    end
  end

  task :cleanup_deleted_products => [:environment] do
    Instance.find(X).set_context!
    Spree::StockLocation.where(company_id: nil).destroy_all
    Spree::StockItem.with_deleted.each { |si| (si.stock_location.nil? || si.variant.nil? || si.variant.product.nil?) ? si.delete! : si }
    Spree::Product.only_deleted.delete_all
    Spree::Variant.only_deleted.delete_all
    Spree::StockItem.only_deleted.delete_all
  end

  task :cleanup_marketplace => [:environment] do
    instance.set_context!
    [Payment,PaymentTransfer,Charge, Payout, Refund, Webhook,
     RecurringBooking, Reservation, ReservationPeriod, Transactable,
     Schedule, AvailabilityTemplate, AvailabilityRule,
     Location, Company, Address, ApprovalRequest,
     ApprovalRequestAttachment, AssignedWaiverAgreementTemplate,
     CategoriesCategorizable, Comment, CompanyIndustry, CompanyUser,
     CreditCard, DataUpload, DocumentsUpload, Impression,
     InstanceClient, MerchantAccount, Photo, RatingAnswer,
     RecurringBookingPeriod, Refund, Review, SavedSearch,
     SavedSearchAlertLog, ScheduleExceptionRule, ScheduleRule,
     Shipment, UserMessage, Support::Ticket, WaiverAgreement,
     Spree::StockLocation, Spree::StockItem, Spree::Product,
     Spree::Variant, Spree::StockItem, Authentication,
     UserRelationship
    ].each do |klass|
      puts "Deleting: #{klass} for #{instance.name}"
      puts "Before count: #{klass.count}"
      if klass.respond_to?(:with_deleted)
        klass = klass.with_deleted
      end
      puts "Removed: #{klass.where(instance_id: instance.id).delete_all}"
      puts "After count: #{klass.count}"
    end
    User.with_deleted.not_admin.where('id NOT IN (SELECT DISTINCT(user_id) FROM instance_admins WHERE deleted_at IS NULL)').where(instance_id: instance.id).delete_all
    AvailabilityTemplate.create!(
      name: "Business Hours",
      parent: instance,
      description: "Monday - Friday, 9am-5pm",
      availability_rules_attributes: [{ open_hour: 9, open_minute: 0, close_hour: 17, close_minute: 0, days: (0..5).to_a }]
    )
    AvailabilityTemplate.create!(
      name: "24/7",
      parent: instance,
      description: "Sunday - Saturday, 12am-11:59pm",
      availability_rules_attributes: [{ open_hour: 0, open_minute: 0, close_hour: 23, close_minute: 59, days: (0..6).to_a }]
    )
  end


  task :destroy_marketplace => [:environment] do
    instance.set_context!
    [Payment,PaymentTransfer,Charge, Payout, Refund, Webhook,
     RecurringBooking, Reservation, ReservationPeriod, Transactable,
     Schedule, AvailabilityTemplate, AvailabilityRule,
     Location, Company, Address, ApprovalRequest,
     ApprovalRequestAttachment, AssignedWaiverAgreementTemplate,
     CategoriesCategorizable, Comment, CompanyIndustry, CompanyUser,
     CreditCard, DataUpload, DocumentsUpload, Impression,
     InstanceClient, MerchantAccount, Photo, RatingAnswer,
     RecurringBookingPeriod, Refund, Review, SavedSearch,
     SavedSearchAlertLog, ScheduleExceptionRule, ScheduleRule,
     Shipment, UserMessage, Support::Ticket, WaiverAgreement,
     Spree::StockLocation, Spree::StockItem, Spree::Product,
     Spree::Variant, Spree::StockItem, Locale, Translation,
     BillingAuthorization, PaymentGateway, Authentication,
     UserRelationship
    ].each do |klass|
      puts "Deleting: #{klass} for #{instance.name}"
      puts "Before count: #{klass.count}"
      if klass.respond_to?(:with_deleted)
        klass = klass.with_deleted
      end
      puts "Removed: #{klass.where(instance_id: instance.id).delete_all}"
      puts "After count: #{klass.count}"
    end
    Domain.with_deleted.where(target: instance).delete_all
    Theme.with_deleted.where(owner: instance).delete_all
    instance.destroy
  end

  task transactable_types_availability_options: :environment do
    Instance.find_each do |instance|
      instance.set_context!
      TransactableType.all.reject(&:valid?).each do |tt|
        tt.update!(availability_options: {
          "defer_availability_rules" => true,
          "confirm_reservations" => {
            "default_value" => true,
            "public" => true
          }
        })
      end
    end
  end

  task fix_missing_country_calling_codes: :environment do
    calling_codes = {
      15 => ['Åland Islands', 358],
      22 => ['Bulgaria', 359],
      26 => ['Saint Barthélemy', 590],
      29 => ['Bolivia, Plurinational State of', 591],
      30 => ['Bonaire, Sint Eustatius and Saba', 599],
      34 => ['Bouvet Island', 47],
      39 => ['Cocos (Keeling) Islands', 61],
      40 => ['Congo, The Democratic Republic of the', 243],
      44 => ["Côte d'Ivoire", 225],
      53 => ['Curaçao', 599],
      55 => ['Cyprus', 357],
      72 => ['Falkland Islands (Malvinas)', 500],
      73 => ['Micronesia, Federated States of', 691],
      90 => ['South Georgia and the South Sandwich Islands', 500],
      96 => ['Heard Island and McDonald Islands', 672],
      108 => ['Iran, Islamic Republic of', 98],
      116 => ['Kyrgyzstan', 996],
      121 => ["Korea, Democratic People's Republic of", 850],
      122 => ["Korea, Republic of", 82],
      126 => ["Lao People's Democratic Republic", 856],
      139 => ["Moldova, Republic of", 373],
      141 => ["Saint Martin (French part)", 590],
      144 => ["Macedonia, Republic of", 389],
      182 => ["Palestinian Territory, Occupied", 970],
      198 => ["Saint Helena, Ascension and Tristan da Cunha", nil],
      207 => ["South Sudan", 211],
      208 => ["Sao Tome and Principe", 239],
      210 => ["Sint Maarten (Dutch part)", 1721],
      211 => ["Syrian Arab Republic", 963],
      215 => ["French Southern Territories", nil],
      228 => ["Tanzania, United Republic of", 255],
      237 => ["Venezuela, Bolivarian Republic of", 58],
      238 => ["Virgin Islands, British", 1284],
      239 => ["Virgin Islands, U.S.", 1340],
      242 => ["Wallis and Futuna", 681],
    }
    Country.where('calling_code is null').each do |country|
      calling_code = calling_codes[country.id].second
      puts "For #{country.name} using calling code #{calling_code}"
      country.update_column(:calling_code, calling_code)
    end
  end

  task fix_wrong_mailers_subjects: :environment do
    puts "Fixing wrong mailers subjects..."

    WorkflowAlert.where(template_path: 'reservation_mailer/notify_host_without_confirmation').update_all(subject: '[{{platform_context.name}}] {{reservation.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!')
    WorkflowAlert.where(template_path: 'reservation_mailer/notify_host_with_confirmation').update_all(subject: '[{{platform_context.name}}] {{reservation.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!')
    WorkflowAlert.where(template_path: 'reengagement_mailer/one_booking').update_all(subject: '[{{platform_context.name}}] Check out these new {{listing.transactable_type.bookable_noun_plural}} in your area!')


    WorkflowAlert.where(template_path: 'recurring_booking_mailer/notify_host_without_confirmation').update_all(subject: '[{{platform_context.name}}] {{recurring_booking.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!')
    WorkflowAlert.where(template_path: 'recurring_booking_mailer/notify_host_with_confirmation').update_all(subject: '[{{platform_context.name}}] {{recurring_booking.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!')

    WorkflowAlert.where(template_path: 'listing_mailer/share').update_all(subject: '{{sharer.name}} has shared a {{listing.transactable_type.bookable_noun}} with you on {{platform_context.name}}')

    WorkflowAlert.where(template_path: 'recurring_mailer/request_photos').update_all(subject: 'Give the final touch to your listings with some photos!')

    WorkflowAlert.where(template_path: 'reengagement_mailer/no_bookings').update_all(subject: '[{{platform_context.name}}] Check out these new listings in your area!')

    puts "[FIXED]"
  end

  desc 'Add metadata with completed_at and draft_at'
  task companies_metadata: :environment do
    Instance.find_each do |instance|
      instance.set_context!
      p "Fixing company's metadata for Instance ##{instance.id}"
      instance.companies.find_each do |company|
        all_transactables = [company.listings.with_deleted, company.products.with_deleted, company.offers.with_deleted].flatten.compact
        completed = all_transactables.none? || all_transactables.any?{ |t| !(t.try(:draft_at) || t.try(:draft)) }
        company.update_metadata({
          draft_at: (completed ? nil : company.created_at),
          completed_at: (completed ? company.created_at : nil)
        })
      end
    end
  end

  task payment_gateway_association: :environment do
    Instance.find_each do |i|
      i.set_context!;
      ps = Payment.all.select { |p| !p.valid? && p.errors.full_messages.join(', ').include?("Payment gateway can't be blank, Payment method can't be blank") } and nil
      if ps.count > 0
        puts "Found #{ps.count} invalid payments for #{i.name}: #{ps.map(&:errors).map(&:full_messages).flatten.uniq.inspect}"
        payment_gateway_missing = ps.select { |p| p.errors.full_messages.join(', ').include?("Payment gateway can't be blank, Payment method can't be blank") }
        puts "\t#{payment_gateway_missing.count} missing payment gateway"
        ps.each do |p|
          if p.payable.nil?
            puts "payable is nil for #{p.id}"
            next
          end
          if p.payable.billing_authorization.present?
            pg_id = p.payable.billing_authorization.payment_gateway_id
            pg = PaymentGateway.unscoped.find_by(id: pg_id)
            if pg.nil?
              puts "epic fail, payment gateway does not exist, removing payment: #{p.id}, #{p.created_at}"
              next
            end
            payment_methods = PaymentMethod.unscoped.where(payment_gateway_id: pg_id)
            pm ||= payment_methods.detect { |pm| pm.payment_method_type == 'free' } if p.is_free?
            pm ||= payment_methods.detect { |pm| pm.payment_method_type == 'manual' } if p.offline? || pg.type = 'PaymentGateway::ManualPaymentGateway'
            pm ||= payment_methods.detect { |pm| !%w(free manual).include?(pm.payment_method_type) }
            puts "Billing authorization present, need to rewrite payment_gateway: #{pg_id} and type #{pm.payment_method_type}"
            p.update_columns(payment_gateway_id: pg.id, payment_method_id: pm.id)
          elsif p.payable.billing_authorizations.count > 0
            pg_id = p.payable.billing_authorizations.last.payment_gateway_id
            pg = PaymentGateway.unscoped.find_by(id: pg_id)
            if pg.nil?
              puts "epic fail, payment gateway does not exist, removing payment: #{p.id}, #{p.created_at}"
              next
            end
            payment_methods = PaymentMethod.unscoped.where(payment_gateway_id: pg_id)
            pm ||= payment_methods.detect { |pm| pm.payment_method_type == 'free' } if p.is_free?
            pm ||= payment_methods.detect { |pm| pm.payment_method_type == 'manual' } if p.offline? || pg.type = 'PaymentGateway::ManualPaymentGateway'
            pm ||= payment_methods.detect { |pm| !%w(free manual).include?(pm.payment_method_type) }
            puts "Billing authorization present, need to rewrite payment_gateway: #{pg_id} and type #{pm.payment_method_type}"
            p.update_columns(payment_gateway_id: pg.id, payment_method_id: pm.id)
          else
            puts "\t\t#{p.id}: #{p.external_transaction_id}, offline: #{p.offline}, first_charge: #{p.charges.first.try(:id)}, possible payment gateway: #{p.instance.payment_gateways(p.payable.company.iso_country_code, p.currency).map(&:type)}"
            if p.external_transaction_id.present? || p.charges.first.present?
              pg = p.instance.payment_gateways(p.payable.company.iso_country_code, p.currency).detect { |p| p.type != 'PaymentGateway::ManualPaymentGateway' }
              if pg
                pm = nil
                pm ||= pg.payment_methods.detect { |pm| pm.payment_method_type == 'free' } if p.is_free?
                pm ||= pg.payment_methods.detect { |pm| pm.payment_method_type == 'manual' } if p.offline?
                pm ||= pg.payment_methods.detect { |pm| !%w(free manual).include?(pm.payment_method_type) }
                puts "\t\t\tTransaction id is present or charge is present, assigning non manual payment gateway: #{pg.type} with type #{pm.payment_method_type} (#{pg.payment_methods.pluck(:payment_method_type)})"
                p.update_columns(payment_gateway_id: pg.id, payment_method_id: pm.id)
                if p.external_transaction_id.blank?
                  puts "\t\t\t\tTransaction id should be additionally populated: #{p.successful_billing_authorization.try(:response).try(:authorization)}"
                end
              else
                puts "epic fail, payment gateway does not exist, removing payment: #{p.id}, #{p.created_at}"
                next
              end
            else
              pg = p.instance.payment_gateways(p.payable.company.iso_country_code, p.currency).detect { |p| p.type == 'PaymentGateway::ManualPaymentGateway' }
              if pg
                pm = pg.payment_methods.detect { |pm| pm.payment_method_type == 'manual' }
                puts "\t\t\tAssigning manual payment gateway: #{pg.type}, type: #{pm.payment_method_type}"
                p.update_columns(payment_gateway_id: pg.id, payment_method_id: pm.id)
              else
                puts "\t\t\tERROR ERROR - no payment gateway (#{p.payment_gateway_mode})"
              end
            end
          end
        end
      else
        puts "#{i.name} is all good!"
      end
    end
  end

  task fix_event_source_for_intel: :environment do
    found = 0
    not_found = 0
    not_found_project = 0

    to_be_destroyed = []

    Instance.where(is_community: true).find_each do |instance|
      instance.set_context!

      ActivityFeedEvent.where(event: 'user_added_photos_to_project', event_source_type: 'Project').order('created_at DESC').find_each do |activity_feed_event|
        affected_objects_identifiers = activity_feed_event.affected_objects_identifiers
        project_id = affected_objects_identifiers.find { |aoi| aoi.match(/Project_/) }.match(/\d+/).to_a[0].to_i
        project = Project.find_by_id(project_id)
        if project.blank?
          not_found_project += 1
          next
        end

        photos = project.photos.order('created_at DESC')

        added_photo = false
        photos.each do |photo|
          activities_with_photo = ActivityFeedEvent.where(event: 'user_added_photos_to_project', event_source: photo).count
          if activities_with_photo.zero?
            found += 1
            added_photo = true

            photo.creator_id = project.creator_id
            photo.save(validate: false)

            activity_feed_event.event_source = photo
            activity_feed_event.flags[:fixed_event_source_photo] = true
            activity_feed_event.save!
            
            break
          end
        end

        not_found += 1 if !added_photo
        to_be_destroyed << activity_feed_event if !added_photo
      end
    end

    to_be_destroyed.each do |tbd|
      tbd.destroy
    end

    puts "Destroyed: #{to_be_destroyed.length}"
    puts "Found: #{found}"
    puts "Not found: #{not_found}"
    puts "Not found project: #{not_found_project}"
  end

  task fix_event_source_for_intel_links: :environment do
    found = 0
    not_found = 0
    not_found_project = 0

    to_be_destroyed = []

    Instance.where(is_community: true).find_each do |instance|
      instance.set_context!

      ActivityFeedEvent.where(event: 'user_added_links_to_project', event_source_type: 'Project').order('created_at DESC').find_each do |activity_feed_event|
        affected_objects_identifiers = activity_feed_event.affected_objects_identifiers
        project_id = affected_objects_identifiers.find { |aoi| aoi.match(/Project_/) }.match(/\d+/).to_a[0].to_i
        project = Project.find_by_id(project_id)
        if project.blank?
          not_found_project += 1
          next
        end

        links = project.links.order('id DESC')

        added_link = false
        links.each do |link|
          activities_with_link = ActivityFeedEvent.where(event: 'user_added_links_to_project', event_source: link).count
          if activities_with_link.zero?
            found += 1
            added_link = true

            activity_feed_event.event_source = link
            activity_feed_event.flags[:fixed_event_source_link] = true
            activity_feed_event.save!
            
            break
          end
        end

        not_found += 1 if !added_link
        to_be_destroyed << activity_feed_event if !added_link
      end
    end

    to_be_destroyed.each do |tbd|
      tbd.destroy
    end

    puts "Destroyed: #{to_be_destroyed.length}"
    puts "Found: #{found}"
    puts "Not found: #{not_found}"
    puts "Not found project: #{not_found_project}"
  end

end

