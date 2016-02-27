namespace :fix do
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
    #instance_id = 75
    instance = Instance.find(instance_id)
    instance.set_context!
    [Payment,PaymentTransfer,Charge, Payout,
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
     Authentication, UserRelationship
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

end

