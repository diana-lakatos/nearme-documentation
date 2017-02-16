namespace :fix do
  task unused_tables: [:environment] do
    connection = ActiveRecord::Base.connection
    connection.tables.collect do |t|
      puts "Processing: #{t}"
      count = connection.select_all("SELECT count(1) as count FROM #{t}", 'Count').first['count']

      puts "\tTABLE UNUSED #{t}" if count.to_i == 0

      columns = connection.columns(t).collect(&:name).reject { |x| x == 'id' }
      columns.each do |column|
        begin
          values = connection.select_all("SELECT DISTINCT(#{column}) AS val FROM #{t} LIMIT 2", 'Distinct Check')
          if values.count == 1
            if values.first['val'].nil?
              puts "\tCOLUMN UNUSED #{t}:#{column}"
            else
              puts "\tCOLUMN SINGLE VALUE #{t}:#{column} -- #{values.first['val']}"
            end
          end
          rescue => e
            puts e.inspect
        end
      end
    end
  end

  task marketplace_errors: [:environment] do
    Instance.find_each do |i|
      i.set_context!
      MarketplaceError.order('id ASC').find_each do |marketplace_error|
        index += 1
        puts "At error #{index}" if index % 10_000 == 0

        group = MarketplaceErrorGroup.where(error_type: marketplace_error.error_type,
                                            message_digest: marketplace_error.message_digest,
                                            instance_id: marketplace_error.instance_id).first_or_create! do |meg|
                                              meg.message = marketplace_error.message
                                              meg.instance_id = marketplace_error.instance_id
                                            end

                                            group.marketplace_errors << marketplace_error
                                            group.update_column(:last_occurence, marketplace_error.created_at)
      end
    end
  end

  task payments_payer: [:environment] do
    Instance.find_each do |i|
      puts "Processing #{i.name}"
      i.set_context!
      Payment.find_each do |p|
        p.update_column(:payer_id, p.payable.owner.id)
      end
    end
  end

  desc 'fixes domain for local use after db rebuild'
  task domains_on_local: [:environment] do
    if Rails.env.development?
      Domain.where("name ilike '%near-me.com%'").find_each do |domain|
        puts "Fixing #{domain.name}"
        domain.update_column :name, domain.name.gsub('near-me.com', 'lvh.me')
      end
      Domain.where(name: 'desksnear.lvh.me', use_as_default: true, target: Instance.first, instance: Instance.first).first_or_create!
    end
  end

  desc 'Fix first period pro-rata'
  task first_period_pro_rata: [:environment] do
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

  task cleanup_marketplace: [:environment] do
    instance.set_context!
    [Payment, PaymentTransfer, Charge, Payout, Refund, Webhook,
     RecurringBooking, Reservation, ReservationPeriod, Transactable,
     Transactable::ActionType, Transactable::Pricing,
     Schedule, AvailabilityTemplate, AvailabilityRule,
     Location, Company, Address, ApprovalRequest,
     ApprovalRequestAttachment, AssignedWaiverAgreementTemplate,
     CategoriesCategorizable, Comment, CompanyUser,
     CreditCard, DataUpload, DocumentsUpload, Impression,
     InstanceClient, MerchantAccount, Photo, RatingAnswer,
     RecurringBookingPeriod, Refund, Review, SavedSearch,
     SavedSearchAlertLog, ScheduleExceptionRule, ScheduleRule,
     Shipment, UserMessage, Support::Ticket, WaiverAgreement,
     Authentication, UserRelationship
    ].each do |klass|
      puts "Deleting: #{klass} for #{instance.name}"
      puts "Before count: #{klass.count}"
      klass = klass.with_deleted if klass.respond_to?(:with_deleted)
      puts "Removed: #{klass.where(instance_id: instance.id).delete_all}"
      puts "After count: #{klass.count}"
    end
    User.with_deleted.not_admin.where('id NOT IN (SELECT DISTINCT(user_id) FROM instance_admins WHERE deleted_at IS NULL)').where(instance_id: instance.id).delete_all
    AvailabilityTemplate.create!(
      name: 'Business Hours',
      parent: instance,
      description: 'Monday - Friday, 9am-5pm',
      availability_rules_attributes: [{ open_hour: 9, open_minute: 0, close_hour: 17, close_minute: 0, days: (0..5).to_a }]
    )
    AvailabilityTemplate.create!(
      name: '24/7',
      parent: instance,
      description: 'Sunday - Saturday, 12am-11:59pm',
      availability_rules_attributes: [{ open_hour: 0, open_minute: 0, close_hour: 23, close_minute: 59, days: (0..6).to_a }]
    )
  end

  Instance.where.not(id: [194, 130, 211]).find_each { |i| begin; i.destroy; rescue; end; }

  task destroy_marketplace: [:environment] do
    instance.set_context!
    [Payment, PaymentTransfer, Charge, Payout, Refund, Webhook,
     RecurringBooking, Reservation, ReservationPeriod, Transactable,
     Transactable::ActionType, Transactable::Pricing,
     Schedule, AvailabilityTemplate, AvailabilityRule,
     Location, Company, Address, ApprovalRequest,
     ApprovalRequestAttachment, AssignedWaiverAgreementTemplate,
     CategoriesCategorizable, Comment, CompanyUser,
     CreditCard, DataUpload, DocumentsUpload, Impression,
     InstanceClient, MerchantAccount, Photo, RatingAnswer,
     RecurringBookingPeriod, Refund, Review, SavedSearch,
     SavedSearchAlertLog, ScheduleExceptionRule, ScheduleRule,
     Shipment, UserMessage, Support::Ticket, WaiverAgreement,
     BillingAuthorization, PaymentGateway, Authentication,
     UserRelationship
    ].each do |klass|
      puts "Deleting: #{klass} for #{instance.name}"
      puts "Before count: #{klass.count}"
      klass = klass.with_deleted if klass.respond_to?(:with_deleted)
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
                     'defer_availability_rules' => true,
                     'confirm_reservations' => {
                       'default_value' => true,
                       'public' => true
                     }
                   })
      end
    end
  end
end
