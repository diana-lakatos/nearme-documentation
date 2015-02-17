namespace :translations do

  desc 'Add dashboard translations'
  task :add_dashboard => [:environment] do
    dashboard_translations = {
      'dashboard.nav.orders' => 'My Orders',
      'dashboard.nav.user_reservations' => 'My Orders',
      'dashboard.nav.user_messages' => 'Messages',
      'dashboard.nav.companies' => 'Shop Details',
      'dashboard.nav.products' => 'Listings',
      'dashboard.nav.transactables' => 'Listings',
      'dashboard.nav.payouts' => 'Payout',
      'dashboard.nav.orders_received' => 'Orders Received',
      'dashboard.nav.host_reservations' => 'Orders Received',
      'dashboard.nav.transfers' => 'Payment Transfers',
      'dashboard.nav.analytics' => 'Analytics',
      'dashboard.nav.users' => 'Manage Admins',
      'dashboard.nav.waiver_agreement_templates' => 'Waiver Agreements',
      'dashboard.nav.white_labels' => 'White-Label',
      'dashboard.nav.tickets' => 'Request for Quote',
      'dashboard.nav.registrations' => 'User Stuff',
      'dashboard.nav.edit' => 'Edit Profile',
      'dashboard.nav.social_accounts' => 'Trust & Verification',
      'dashboard.nav.notification_preferences' => 'Notification Preferences',
      'dashboard.nav.user_recurring_bookings' => 'My Orders',
      'dashboard.nav.host_recurring_bookings' => 'Orders Received',
      'dashboard.nav.your_shop' => 'YOUR SHOP',
      'dashboard.nav.admin' => 'ADMIN',
      'dashboard.nav.account' => 'ACCOUNT',
      'dashboard.nav.menu' => 'MENU',
      'dashboard.nav.blog' => 'BLOG',
    }

    create_keys(dashboard_translations)
  end

  desc 'Add wish lists translations'
  task :add_wish_lists => [:environment] do
    wish_lists_translations = {
      'wish_lists.name' => 'Favorites',
      'wish_lists.buttons.clear' => 'Remove all',
      'wish_lists.buttons.unselected_state' => 'Add to favorites',
      'wish_lists.buttons.selected_state' => 'Remove from favorites',

    }

    create_keys(wish_lists_translations)
  end

  desc 'Add NM-1363 translations'
  task :add_1363_translations => [:environment] do
    nm_1363_translations = {
      'simple_form.labels.location.name' => 'Location name',
      'simple_form.hints.location.name' => 'A unique title that describes the location.',
      'simple_form.labels.location.description' => 'Location description',
      'simple_form.labels.location.location_type' => 'Location type',
      'simple_form.labels.location.email' => 'Booking email',
      'simple_form.placeholders.location.email' => 'Your booking email',
      'simple_form.labels.location.administrator' => 'Administrator',
      'simple_form.prompts.location.administrator' => 'Default',
      'simple_form.labels.location.special_notes' => '%{lessee} instructions',
      'simple_form.placeholders.location.special_notes' => "For example, how your %{lessees} should check in, your Wi-Fi password, whether you have pets, or other special information relevant to your %{lessee}'s stay",
      'simple_form.labels.location.currency' => 'Currency',
      'simple_form.labels.location.location_address.address' => 'Address',
      'simple_form.labels.location.amenities' => 'Amenities',


      'simple_form.labels.company.name' => 'Company name',
      'simple_form.placeholders.company.name' => 'Enter your business name',
      'simple_form.labels.company.description' => 'Description',
      'simple_form.placeholders.company.description' => 'Give a brief description of your company.',
      'simple_form.labels.company.industries' => 'Industries',
      'simple_form.prompts.company.industries' => 'Select one or more',
      'simple_form.labels.company.url' => 'Website',
      'simple_form.placeholders.company.url' => 'www.mycompany.com',
      'simple_form.labels.company.email' => 'Company email',
      'simple_form.placeholders.company.email' => 'yourname@example.com',
      'simple_form.labels.company.company_address.address' => 'Address',
      'simple_form.placeholders.company.company_address.address' => 'Where is your store located?',
      'simple_form.labels.company.mailing_address' => 'Mailing address',
      'simple_form.hints.company.mailing_address' => 'Checks for revenue will be sent to this address. Find out more about payments in the Support Center.',
      'simple_form.labels.company.paypal_email' => 'PayPal email',
      'simple_form.hints.company.paypal_email' => 'If you specify a PayPal email, we will make a PayPal transfer instead of sending checks.',
      'simple_form.labels.company.bank_owner_name' => "Account's Owner Name",
      'simple_form.labels.company.bank_routing_number' => 'Routing Number',
      'simple_form.labels.company.bank_account_number' => 'Account Number',
      'simple_form.labels.company.company_address.address' => 'Address',
      'simple_form.labels.company.payout.via_paypal' => 'Payouts via Paypal',
      'simple_form.labels.company.payout.via_ach' => 'Payouts via ACH (US only)',
      'simple_form.labels.company.payout.ach_update' => 'Update bank account details for ACH payouts',
      'simple_form.labels.company.payout.ach_error' => 'Unfortunately we could not process the credentials you have entered.',

      'simple_form.labels.transactable.name' => 'Item Title',
      'simple_form.labels.transactable.price_daily' => 'Daily',
      'simple_form.labels.transactable.price_weekly' => 'Weekly',
      'simple_form.labels.transactable.price_monthly' => 'Monthly',
      'simple_form.labels.transactable.price_hourly' => 'Hourly',
      'simple_form.labels.transactable.price_free' => 'Free',
      'simple_form.labels.transactable.price.daily' => 'day',
      'simple_form.labels.transactable.price.weekly' => 'week',
      'simple_form.labels.transactable.price.monthly' => 'month',
      'simple_form.labels.transactable.price.hourly' => 'hour',

      'simple_form.labels.availability_rule.open' => 'Open',
      'simple_form.labels.availability_template.custom' => 'Custom',
      'simple_form.labels.availability_template.use_parent_availability' => 'Use Location availability',
      'simple_form.labels.availability_template.full_name.working_week' => 'Working Week (Mon - Fri, 9:00 AM - 5:00 PM)'
    }

    create_keys(nm_1363_translations)
  end

  def create_keys(hash)
    hash.each do |k, v|
      if Translation.where(key: k).empty?
        puts "creating translation #{k}: #{v}"
        Translation.create(locale: 'en', key: k, value: v)
      else
        puts "translation already exists #{k}: #{v}"
      end
    end
  end
end
