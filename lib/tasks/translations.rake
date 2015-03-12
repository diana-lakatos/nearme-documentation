namespace :translations do

  desc 'Add dashboard translations'
  task :add_dashboard => [:environment] do
    dashboard_translations = {
      'dashboard.nav.orders' => 'My Orders',
      'dashboard.nav.user_reservations' => 'My Bookings',
      'dashboard.nav.user_messages' => 'Messages',
      'dashboard.nav.companies' => 'Shop Details',
      'dashboard.nav.products' => 'My Products',
      'dashboard.nav.transactables' => 'My Listings',
      'dashboard.nav.payouts' => 'Payout',
      'dashboard.nav.orders_received' => 'Orders Received',
      'dashboard.nav.host_reservations' => 'Bookings Received',
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
      'dashboard.nav.user_recurring_bookings' => 'My Bookings',
      'dashboard.nav.host_recurring_bookings' => 'Bookings Received',
      'dashboard.nav.your_shop' => 'YOUR SHOP',
      'dashboard.nav.admin' => 'ADMIN',
      'dashboard.nav.account' => 'ACCOUNT',
      'dashboard.nav.menu' => 'MENU',
      'dashboard.nav.blog' => 'BLOG',
      'dashboard.nav.services_header' => "SERVICES",
      'dashboard.nav.products_header' => "PRODUCTS",
      'dashboard.products.manage' => 'MANAGE PRODUCTS',
      'dashboard.transactables.manage' => 'MANAGE LISTINGS'
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
      'simple_form.labels.availability_template.full_name.working_week' => 'Working Week (Mon - Fri, 9:00 AM - 5:00 PM)',

      'top_navbar.sign_up' => 'Sign up',
      'top_navbar.log_in' => 'Log in',
      'top_navbar.manage_blog' => 'Manage blog',
      'top_navbar.account' => 'Account',
      'top_navbar.messages' => 'Messages',
      'top_navbar.log_out' => 'Log out',
      'top_navbar.my_bookings' => 'My Bookings',
      'top_navbar.my_orders' => 'My Orders',
      'top_navbar.manage_bookable' => 'Manage %{bookable_noun}',
      'top_navbar.marketplace_admin' => 'Marketplace Admin',
      'top_navbar.cart' => 'CART %{cart}',
      'wish_lists.name' => 'Favorites',
      'reservations.rfq_menu_text' => 'My RFQs',
      'ui.header.complete_your_thing' => 'Complete Your %{thing}',
      'ui.header.list_your_thing' => 'List Your %{thing}',
      'ui.header.list_your' => 'List Your ...',

      'sign_up_form.sign_up_to' => 'Sign up to %{marketplace_name}',
      'sign_up_form.log_in_to' => 'Log in to %{marketplace_name}',
      'sign_up_form.confirm_tos' => 'By signing up, you confirm that you accept the',
      'sign_up_form.tos' => 'Terms of Service and Privacy Policy',
      'sign_up_form.title' => 'Sign in',
      'sign_up_form.buttons.sign_up' => 'Sign up',
      'sign_up_form.buttons.log_in' => 'Log in',
      'sign_up_form.buttons.close' => 'Close',
      'sign_up_form.buttons.sign_up.reset_password' => 'Reset your password',
      'sign_up_form.buttons.already_user' => 'Already a user?',
      'sign_up_form.buttons.new_user' => 'New User?',
      'sign_up_form.disabled_buttons.sign_up' => 'Signing up...',
      'sign_up_form.forgot' => 'Forgot?',
      'sign_up_form.more_details' => 'We just need a couple more details:',

      'reset_password_form.title' => 'Reset Password',
      'reset_password_form.heading' => 'Reset Your Password',
      'reset_password_form.instructions' => "Enter your new password below and we'll update your account.",
      'reset_password_form.instructions_email' => "Fill in your email below and we'll send you instructions to reset your password.",
      'reset_password_form.buttons.change' => 'Change Password',
      'reset_password_form.buttons.reset' => 'Reset Password',

      'simple_form.placeholders.registration.name' => 'Full name',
      'simple_form.placeholders.registration.email' => 'Email',
      'simple_form.placeholders.registration.password' => 'Password',
      'simple_form.labels.registration.email' => 'Your email address',
      'simple_form.placeholders.registration.we_can_contact_you' => 'So we can contact you',

      'simple_form.placeholders.session.email' => 'Email',
      'simple_form.placeholders.session.password' => 'Password',

      'homepage.buttons.search' => 'Search',
      'homepage.disabled_buttons.search' => 'Searching...',
      'homepage.search_field_placeholder.full_text' => 'Search by keyword',
      'homepage.search_field_placeholder.location' => 'Search by city or address',
      'homepage.search_field_placeholder.search' => 'Search',

      'location.the_location' => 'The location',
      'location.hours' => 'Hours',
      'location.amenities' => 'Amenities',
      'location.confirmations.admin_login' => 'This will log you out and re-log you in as location administrator.',
      'location.buttons.view_profile' => 'View profile',
      'location.buttons.contact' => 'Contact',
      'location.company.industries' => 'Industries',

      'booking_module.description' => 'Description',
      'booking_module.hours' => 'Hours',
      'booking_module.free' => 'Free',
      'booking_module.start' => 'Start',
      'booking_module.end' => 'End',
      'booking_module.nine' => '9:00am',
      'booking_module.weekly_on' => 'Weekly on',
      'booking_module.custom' => 'Custom',
      'booking_module.total' => 'Total',
      'booking_module.notices.days_first' => 'Please select days first',

      'reservations_review.heading' => 'Review your booking',
      'reservations_review.summary' => 'Order summary',
      'reservations_review.subtotal' => 'Subtotal',
      'reservations_review.service_fee' => 'Service fee',
      'reservations_review.total' => 'Total',
      'reservations_review.contact_information' => 'Contact information',
      'reservations_review.select_payment_method' => 'Select Payment Method',
      'reservations_review.credit_card' => 'Credit Card',
      'reservations_review.paypal' => 'PayPal',
      'reservations_review.payment' => 'Payment',
      'reservations_review.submit_secure_payment' => 'Submit a secure payment.',
      'reservations_review.cc_image_alt' => 'Visa, Mastercard, American Express, Discover',
      'reservations_review.wat_accept' => 'I have read and accept %{link_to_wat}',
      'reservations_review.buttons.request' => 'Request Booking',
      'reservations_review.disabled_buttons.request' => 'Booking...',
      'reservations_review.errors.whoops' => "Whoops! We couldn't make that reservation.",

      'recurring_reservations_review.total' => 'Total per reservation',
      'recurring_reservations_review.errors.whoops' => "Whoops! We couldn't make that recurring purchase.",

      'payments.heading' => 'Submit a secure payment.',
      'payments.cc_image_alt' => 'Visa, Mastercard, American Express, Discover',
      'payments.cc_fields.first_name' => 'First Name',
      'payments.cc_fields.last_name' => 'Last Name',
      'payments.cc_fields.card_number' => 'Card number',
      'payments.cc_fields.expiration_date' => 'Expiration date',
      'payments.cc_fields.security_code' => 'Security code',

      'simple_form.labels.locations.name' => 'Location name',
      'simple_form.labels.locations.description' => 'Location description',
      'simple_form.labels.locations.location_address.address' => 'Address',
      'simple_form.labels.locations.location_type' => 'Location type',

      'simple_form.labels.companies.name' => 'Company name',
      'simple_form.placeholders.companies.name' => 'Enter your business name',
      'simple_form.labels.companies.industries' => 'Industries',
      'simple_form.labels.companies.description' => 'Description',
      'simple_form.placeholders.companies.description' => 'Give a brief description of your company.',
      'simple_form.labels.companies.url' => 'Website',
      'simple_form.placeholders.companies.url' => 'www.mycompany.com',
      'simple_form.labels.companies.email' => 'Company email',
      'simple_form.placeholders.companies.email' => 'yourname@example.com',
      'simple_form.labels.companies.company_address.address' => 'Address',
      'simple_form.prompts.companies.industries' => 'Select one or more',

      'simple_form.labels.listings.price' => 'Price',
      'simple_form.labels.listings.photos' => 'Photos',
      'simple_form.labels.listings.upload_photos' => 'Browse',
    }

    create_keys(nm_1363_translations)
  end

  desc 'Clean NM-1331 translations'
  task :clean_nm_1331 => [:environment] do
    wish_lists_translations = [
      'wish_lists.name',
      'wish_lists.buttons.clear',
      'wish_lists.buttons.unselected_state',
      'wish_lists.buttons.selected_state'
    ]

    wish_lists_translations.each { |key| Translation.where(key: key).destroy_all }
  end

  desc 'Upload documents translations'
  task :upload_documents => [:environment] do
    upload_documents_translations = {
      'upload_documents.file.default.label' => 'Secure Document Upload',
      'upload_documents.file.default.description' => 'Please upload your document here.'
    }
    create_keys(upload_documents_translations)
  end

  desc 'Update translations'
  task :update => [:environment] do
    keys_to_update = {
      'location.social_share.twitter' => 'Check out @%{instance_name}',
      'flash_messages.manage.locations.space_added' => 'Great, your new location has been added!'
    }
    create_keys(keys_to_update)
  end

  def create_keys(hash)
    hash.each do |k, v|
      translations = Translation.where(locale: 'en', key: k, instance_id: nil)
      if translations.any?
        translations.each do |t|
          old_value = t.value
          t.value = v
          puts "Key |#{k}| updated from |#{old_value}| to |#{v}|" if t.changed? && t.save
        end
      else
        puts "creating translation #{k}: #{v}"
        Translation.create(locale: 'en', key: k, value: v)
      end
    end
  end
end
