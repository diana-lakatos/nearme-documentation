class CleanupDbMigration < ActiveRecord::Migration
  def up
    drop_table :bids
    drop_table :countries_shipping_rules
    drop_table :industries
    drop_table :user_industries
    drop_table :inquiries
    drop_table :partner_inquiries
    drop_table :instance_types
    drop_table :listing_types
    drop_table :offers
    drop_table :old_recurring_booking_periods
    drop_table :recurring_bookings
    drop_table :reservations
    drop_table :reservation_seats
    drop_table :spree_option_values_variants
    drop_table :user_instance_profiles
    drop_table :email_templates

    remove_column :categories, :user_id
    remove_column :categories, :description
    remove_column :categories, :meta_title
    remove_column :categories, :meta_description
    remove_column :categories, :meta_keywords
    remove_column :categories, :in_top_nav
    remove_column :categories, :top_nav_positions

    remove_column :charge_types, :provider_commission_percentage

    remove_column :countries, :instance_id
    remove_column :countries, :company_id
    remove_column :countries, :partner_id
    remove_column :countries, :user_id

    remove_column :line_items, :partner_id
    remove_column :line_items, :company_id

    remove_column :host_fee_line_items, :user_id
    remove_column :host_fee_line_items, :company_id
    remove_column :host_fee_line_items, :partner_id

    remove_column :host_line_items, :user_id
    remove_column :host_line_items, :company_id
    remove_column :host_line_items, :partner_id

    remove_column :instance_views, :instance_type_id

    remove_column :merchant_accounts, :gateway_class
    remove_column :merchant_accounts, :enabled

    remove_column :orders, :partner_id
    remove_column :orders, :create_charge
    remove_column :orders, :listings_public
    remove_column :orders, :booking_type
    remove_column :orders, :completed_at

    remove_column :payment_gateways_countries, :company_id
    remove_column :payment_gateways_countries, :partner_id

    remove_column :payment_gateways_currencies, :company_id
    remove_column :payment_gateways_currencies, :partner_id

    remove_column :payment_methods, :company_id
    remove_column :payment_methods, :partner_id

    remove_column :payment_subscriptions, :partner_id

    remove_column :refunds, :credit_card_id

    remove_column :reservation_periods, :line_item_id

    remove_column :support_ticket_message_attachments, :description
    remove_column :support_ticket_message_attachments, :receiver_id
    remove_column :support_ticket_message_attachments, :target_id
    remove_column :support_ticket_message_attachments, :target_type

    remove_column :transactables, :instance_type_id
    remove_column :transactables, :listing_type_id
    remove_column :transactables, :parent_transactable_id
    remove_column :transactables, :hourly_price_cents
    remove_column :transactables, :daily_price_cents
    remove_column :transactables, :weekly_price_cents
    remove_column :transactables, :monthly_price_cents
    remove_column :transactables, :fixed_price_cents
    remove_column :transactables, :min_fixed_price_cents
    remove_column :transactables, :max_fixed_price_cents
    remove_column :transactables, :book_it_out_discount
    remove_column :transactables, :book_it_out_minimum_qty
    remove_column :transactables, :exclusive_price_cents
    remove_column :transactables, :weekly_subscription_price_cents
    remove_column :transactables, :monthly_subscription_price_cents
    remove_column :transactables, :deposit_amount_cents
    remove_column :transactables, :spree_product_id

    remove_column :transactable_types, :min_fixed_price_cents
    remove_column :transactable_types, :max_fixed_price_cents

    remove_column :users, :locked_at
    remove_column :users, :unconfirmed_email
    remove_column :users, :unlock_token
    remove_column :users, :spree_api_key
    remove_column :users, :paypal_merchant_id
    remove_column :users, :twitter_url
    remove_column :users, :linkedin_url
    remove_column :users, :facebook_url
    remove_column :users, :google_plus_url

    remove_column :workflow_alert_monthly_aggregated_logs, :workflow_alert_id
    remove_column :workflow_alert_monthly_aggregated_logs, :integer

    remove_column :workflow_alert_weekly_aggregated_logs, :integer

    remove_column :workflow_alerts, :options

    remove_column :instances, :instance_type_id
    remove_column :instances, :priority_view_path
    remove_column :instances, :service_fee_host_percent
    remove_column :instances, :live_stripe_public_key
    remove_column :instances, :paypal_email
    remove_column :instances, :encrypted_live_paypal_username
    remove_column :instances, :encrypted_live_paypal_password
    remove_column :instances, :encrypted_live_paypal_signature
    remove_column :instances, :encrypted_live_paypal_app_id
    remove_column :instances, :encrypted_live_paypal_client_id
    remove_column :instances, :encrypted_live_paypal_client_secret
    remove_column :instances, :encrypted_live_stripe_api_key
    remove_column :instances, :encrypted_test_paypal_username
    remove_column :instances, :encrypted_test_paypal_password
    remove_column :instances, :encrypted_test_paypal_signature
    remove_column :instances, :encrypted_test_paypal_app_id
    remove_column :instances, :encrypted_test_paypal_client_id
    remove_column :instances, :encrypted_test_paypal_client_secret
    remove_column :instances, :encrypted_test_stripe_api_key
    remove_column :instances, :test_stripe_public_key
    remove_column :instances, :stripe_currency
    remove_column :instances, :user_required_fields
  end

  def down
  end
end
