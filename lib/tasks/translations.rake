namespace :translations do

  desc "Add dashboard translations"
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

    dashboard_translations.each do |k,v|
      if Translation.where(key: k).empty?
        puts "creating translation #{k}: #{v}"
        Translation.create(locale: 'en', key: k, value: v)
      else
        puts "translation already exists #{k}: #{v}"
      end
    end
  end

end
