class InstanceView < ActiveRecord::Base
  include Cacheable

  has_paper_trail
  belongs_to :instance_type
  belongs_to :instance
  belongs_to :transactable_type

  VIEW_VIEW = 'view'
  EMAIL_VIEW = 'email'
  SMS_VIEW = 'sms'
  EMAIL_LAYOUT_VIEW = 'mail_layout'
  VIEW_TYPES = [SMS_VIEW, EMAIL_VIEW, EMAIL_LAYOUT_VIEW, VIEW_VIEW]

  DEFAULT_EMAIL_TEMPLATES_PATHS = [
    'post_action_mailer/sign_up_welcome', 'post_action_mailer/sign_up_verify',
    'post_action_mailer/created_by_instance_admin', 'post_action_mailer/list',
    'post_action_mailer/list_draft', 'post_action_mailer/unsubscription',
    'post_action_mailer/user_created_invitation',
    'inquiry_mailer/inquiring_user_notification',
    'inquiry_mailer/listing_creator_notification', 'listing_mailer/share',
    'payment_gateway_mailer/notify_host_about_payout_failure_email',
    'payment_gateway_mailer/notify_host_of_merchant_account_declinal',
    'payment_gateway_mailer/notify_host_of_merchant_account_approval',
    'rating_mailer/request_rating_of_guest_from_host',
    'rating_mailer/request_rating_of_host_from_guest',
    'reengagement_mailer/no_bookings', 'reengagement_mailer/one_booking',
    'recurring_mailer/analytics', 'recurring_mailer/request_photos',
    'recurring_mailer/share', 'reservation_mailer/notify_guest_of_cancellation_by_guest',
    'reservation_mailer/notify_guest_of_cancellation_by_host',
    'reservation_mailer/notify_guest_of_confirmation', 'reservation_mailer/notify_guest_of_expiration',
    'reservation_mailer/notify_guest_of_rejection', 'reservation_mailer/notify_guest_with_confirmation',
    'reservation_mailer/notify_host_of_cancellation_by_guest',
    'reservation_mailer/notify_host_of_cancellation_by_host',
    'reservation_mailer/notify_host_of_confirmation', 'reservation_mailer/notify_host_of_expiration',
    'reservation_mailer/notify_host_of_rejection', 'reservation_mailer/notify_host_with_confirmation',
    'reservation_mailer/notify_host_without_confirmation', 'reservation_mailer/pre_booking',
    'reservation_mailer/notify_guest_of_payment_request',
    'reservation_mailer/notify_guest_of_shipping_details', 'reservation_mailer/notify_host_of_shipping_details',
    'rating_mailer/line_items/request_rating_of_guest_from_host',
    'rating_mailer/line_items/request_rating_of_host_and_product_from_guest',
    'spree/order_mailer/approved_email', 'spree/order_mailer/cancel_email',
    'spree/order_mailer/confirm_email', 'spree/order_mailer/notify_seller_email',
    'spree/order_mailer/shipping_info_for_buyer', 'spree/order_mailer/shipping_info_for_seller',
    'spree/shipment_mailer/shipped_email', 'support_mailer/rfq_request_received',
    'support_mailer/rfq_request_replied', 'support_mailer/rfq_request_updated',
    'support_mailer/rfq_support_received', 'support_mailer/rfq_support_updated',
    'support_mailer/request_received', 'support_mailer/support_received',
    'support_mailer/request_updated', 'support_mailer/request_replied',
    'support_mailer/support_updated', 'company_mailer/notify_host_of_no_payout_option',
    'post_action_mailer/instance_created',
    'user_message_mailer/email_message_from_host', 'user_message_mailer/email_message_from_guest',
    'data_upload_mailer/notify_uploader_of_failed_import',
    'data_upload_mailer/notify_uploader_of_finished_import',
    'vendor_approval_mailer/notify_admin_of_new_listings',
    'vendor_approval_mailer/notify_host_of_listing_approval',
    'vendor_approval_mailer/notify_host_of_listing_rejection',
    'vendor_approval_mailer/notify_host_of_listing_questioned',
    'vendor_approval_mailer/notify_host_of_user_approval',
    'user_mailer/notify_about_wrong_phone_number',
    'user_mailer/notify_about_unread_messages',

  ].freeze

  DEFAULT_SMS_TEMPLATES_PATHS = [
    'company_sms_notifier/notify_host_of_no_payout_option',
    'recurring_booking_sms_notifier/notify_guest_with_state_change',
    'recurring_booking_sms_notifier/notify_host_with_confirmation',
    'reservation_sms_notifier/notify_guest_with_state_change',
    'reservation_sms_notifier/notify_host_with_confirmation',
    'user_message_sms_notifier/notify_user_about_new_message'

  ].freeze

  DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS = ['layouts/mailer'].freeze

  # Contains documentation to be parsed by the documentation parser
  # Please keep it up-to-date when adding/modifying new liquid views to
  # this array.
  DEFAULT_LIQUID_VIEWS_PATHS = {
    'locations/booking_module_listing_description' => {
      listing: 'TransactableDrop'
    },
    'locations/location_description' => {
      location: 'LocationDrop'
    },
    'locations/listings/listing_description' => {
      listing: 'TransactableDrop'
    },
    'locations/booking_module_call_to_actions' => {
      listing: 'TransactableDrop',
      book_hash: 'booking information array',
      rfq_class: 'string',
      rfq_label: 'string'
    },
    'locations/booking_module_listing_description_below_dates' => {
      listing: 'TransactableDrop'
    },
    'locations/booking_module_listing_description_below_call_to_action' => {
      listing: 'TransactableDrop'
    },
    'locations/booking_module_listing_description_above_call_to_action' => {
      listing: 'TransactableDrop'
    },
    'registrations/profile/user_badge' => {
      platform_context: 'PlatformContextDrop',
      user: 'UserDrop',
      is_current_user: 'boolean; true if logged in user is viewing user',
      company: 'CompanyDrop'
    },
    'locations/google_map' => {
      location: 'LocationDrop'
    },
    'locations/administrator' => {
      administrator: 'UserDrop',
      listing: 'TransactableDrop'
    },
    'buy_sell_market/products/extra_properties' => {
      product: 'Spree::ProductDrop'
    },
    'search/mixed/location' => {
      location: 'LocationDrop',
      location_counter: 'integer, index of this location among the search results on this page',
      transactable_type: 'TransactableTypeDrop',
      current_page_offset: 'integer, index of the first location on this page among the search results',
      lgpricing_filters: 'array of pricing type filters (e.g. daily, weekly, hourly etc.)'
    },
    'search/mixed/listing' => {
      listing: 'TransactableDrop',
      lgpricing_filters: 'array of pricing type filters (e.g. daily, weekly, hourly etc.)'
    },
    'search/mixed/individual_listing' => {
      listing: 'TransactableDrop',
      listing_counter: 'integer, index of this location among the search results on this page',
      transactable_type: 'TransactableTypeDrop',
      current_page_offset: 'integer, index of the first location on this page among the search results',
      lgpricing_filters: 'array of pricing type filters (e.g. daily, weekly, hourly etc.)'
    },
    'search/list/listing' => {
      listing: 'TransactableDrop',
      current_user: 'UserDrop'
    },
    'search/list/user' => {
      user: 'UserDrop',
      current_user: 'UserDrop'
    },
    'search/products/product' => {
      product: 'Spree::ProductDrop'
    },
    'search/products_table/head' => {
    },
    'search/footer' => {
      transactable_type: 'ServiceTypeDrop or ProductTypeDrop',
      searcher: 'The search results for this page'
    },
    'search/products_table/product' => {
      product: 'Spree::ProductDrop'
    },
    'reservation_mailer/social_links' => {
      platform_context: 'PlatformContextDrop',
      listing: 'TransactableDrop'
    },
    'support_mailer/rfq_review' => {
      platform_context: 'PlatformContextDrop',
      ticket: 'Support::TicketDrop'
    },
    'support_mailer/rfq_message_history' => {
      ticket: 'Support::TicketDrop'
    },
    'support_mailer/new_message_separator' => {
    },
    'support_mailer/rfq_host_review' => {
      ticket: 'Support::TicketDrop',
      platform_context: 'PlatformContextDrop'
    },
    'reservation_mailer/listings_in_near' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/blog/header' => {
      blog_post: 'UserBlogPostDrop',
      user: 'UserDrop'
    },
    'registrations/blog/social_buttons' => {
      blog_post: 'UserBlogPostDrop',
      user: 'UserDrop'
    },
    'registrations/blog/blog_post' => {
      blog_post: 'UserBlogPostDrop',
      user: 'UserDrop'
    },
    'registrations/blog/show' => {
      blog_post: 'UserBlogPostDrop',
      user: 'UserDrop',
      is_partial: false
    },
    'registrations/blog/index' => {
      blog_posts: 'UserBlogPostDrop',
      user: 'UserDrop',
      is_partial: false
    },
    'registrations/buyers/profile/no_content' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/profile/user_badge' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/profile/tabs/blog_posts' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/profile/tabs/products' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/profile/tabs/reviews' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/profile/tabs/services' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/show' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop',
      is_partial: false
    },
    'registrations/sellers/profile/no_content' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/sellers/profile/user_badge' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/sellers/profile/tabs/blog_posts' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/sellers/profile/tabs/products' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/sellers/profile/tabs/reviews' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/sellers/profile/tabs/services' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/sellers/show' => {
      user: 'UserDrop',
      platform_context: 'PlatformContextDrop',
      is_partial: false
    },
    'blog/blog_posts/header' => {
      blog_post: 'BlogPostDrop',
      blog_instance: 'BlogInstanceDrop',
      is_partial: true
    },
    'blog/blog_posts/social_buttons' => {
      blog_post: 'BlogPostDrop',
      blog_instance: 'BlogInstanceDrop',
      is_partial: true
    },
    'blog/blog_posts/blog_post' => {
      blog_post: 'BlogPostDrop',
      blog_instance: 'BlogInstanceDrop',
      is_partial: true
    },
    'blog/blog_posts/show' => {
      blog_post: 'BlogPostDrop',
      blog_instance: 'BlogInstanceDrop',
      is_partial: false
    },
    'blog/blog_posts/index' => {
      blog_posts: 'BlogPostDrop',
      blog_instance: 'BlogInstanceDrop',
      is_partial: false
    },
    'dashboard/wish_list_items/wish_list_item' => {
      'wish_list_item': 'WishListItemDrop',
      is_partial: true
    },
    'listings/recurring_bookings/header' => {
      'listing': 'TransactableDrop',
      'location': 'LocationDrop',
      is_partial: true
    },
    'listings/reservations/header' => {
      'listing': 'TransactableDrop',
      'location': 'LocationDrop',
      is_partial: true
    },
    'locations/twitter_social_button' => {
      'location': 'LocationDrop',
      is_partial: true
    },
    'registrations/profile/tabs/transactable' => {
      'transactable': 'TransactableDrop',
      is_partial: true
    },
    'buy_sell_market/products/above_cart_management' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/above_social_buttons' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/above_wish_lists' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/below_cart_module' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/extra_tab_panes' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/extra_tab_titles' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/name_and_price' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/product_description' => {
      'product': 'Spree::ProductDrop',
    },
    'buy_sell_market/products/seller_attachments' => {
      'product': 'Spree::ProductDrop',
      'attachments': 'list of seller attachments',
    },
    'buy_sell_market/products/administrator_badge' => {
      'product': 'Spree::ProductDrop',
    },
  }.freeze

  scope :for_instance_type_id, ->(instance_type_id) {
    where('instance_type_id IS NULL OR instance_type_id = ?', instance_type_id)
  }

  scope :for_instance_id, ->(instance_id) {
    where('instance_id IS NULL OR instance_id = ?', instance_id)
  }

  scope :for_nil_transactable_type, ->  { where(transactable_type_id: nil) }
  scope :for_not_nil_transactable_type, ->  { where.not(transactable_type_id: nil) }


  scope :for_transactable_type_id, -> (transactable_type_id) {
    where('transactable_type_id IS NULL OR transactable_type_id = ?', transactable_type_id)
  }

  scope :liquid_views, -> {
    custom_views.where(handler: 'liquid')
  }

  scope :custom_views, -> {
    where(view_type: VIEW_VIEW)
  }

  scope :custom_smses, -> {
    where(view_type: SMS_VIEW, format: 'text', handler: 'liquid')
  }

  scope :custom_emails, -> {
    where(view_type: EMAIL_VIEW, format: ['text', 'html'], handler: 'liquid')
  }

  scope :custom_email_layouts, -> {
    where(view_type: EMAIL_LAYOUT_VIEW, format: ['text', 'html'], handler: 'liquid')
  }

  def self.all_email_templates_paths
    (DEFAULT_EMAIL_TEMPLATES_PATHS + self.for_instance_id(PlatformContext.current.instance.id).custom_emails.pluck(:path)).uniq
  end

  def self.email_templates_paths_wo_transactable_type
    all_email_templates_paths - self.for_instance_id(PlatformContext.current.instance.id).custom_emails.for_not_nil_transactable_type.pluck(:path)
  end

  def self.not_customized_sms_templates_paths
    DEFAULT_SMS_TEMPLATES_PATHS - self.for_instance_id(PlatformContext.current.instance.id).custom_smses.pluck(:path)
  end

  def self.not_customized_liquid_views_paths
    DEFAULT_LIQUID_VIEWS_PATHS.keys - self.for_instance_id(PlatformContext.current.instance.id).liquid_views.pluck(:path)
  end

  def self.not_customized_email_templates_paths
    custom_paths = self.for_instance_id(PlatformContext.current.instance.id).custom_emails.pluck(:path, :format).inject({}) do |hash, arr|
      hash[arr[0]] ||= []
      hash[arr[0]] << arr[1]
      hash
    end

    DEFAULT_EMAIL_TEMPLATES_PATHS.each do |path|
      custom_paths[path] ||= []
    end
    custom_paths
  end

  def self.all_email_template_layouts_paths
    (DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS + self.for_instance_id(PlatformContext.current.instance.id).custom_email_layouts.pluck(:path)).uniq
  end

  def self.all_sms_template_layouts_paths
    (DEFAULT_SMS_TEMPLATES_PATHS + self.for_instance_id(PlatformContext.current.instance.id).custom_smses.pluck(:path)).uniq
  end

  def self.not_customized_email_template_layouts_paths
    custom_paths = self.for_instance_id(PlatformContext.current.instance.id).custom_email_layouts.pluck(:path, :format).inject({}) do |hash, arr|
      hash[arr[0]] ||= []
      hash[arr[0]] << arr[1]
      hash
    end

    DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS.each do |path|
      custom_paths[path] ||= []
    end
    custom_paths
  end

  validates_presence_of :body
  validates_presence_of :path
  validates_inclusion_of :locale, in: I18n.available_locales.map(&:to_s)
  validates_inclusion_of :handler, in: ActionView::Template::Handlers.extensions.map(&:to_s)
  validates_inclusion_of :format, in: Mime::SET.symbols.map(&:to_s)
  validates_uniqueness_of :path, { scope: [:instance_id, :transactable_type_id, :locale, :format, :handler, :partial] }
  validate :template_path_is_accessible_for_all_alerts, if: lambda { |instance_view| instance_view.transactable_type_id.present? }

  before_validation do
    self.locale ||= 'en'
  end

  def template_path_is_accessible_for_all_alerts
    workflow_alerts_which_will_ignore_this_instance_view = WorkflowAlert.where(template_path: path).reject(&:makes_sense_to_associate_with_transactable_type?)
    if workflow_alerts_which_will_ignore_this_instance_view.count > 0
      self.errors.add(:transactable_type_id, I18n.t('activerecord.errors.models.instance_view.attributes.service_type.not_accessible', workflow_alerts: workflow_alerts_which_will_ignore_this_instance_view.map { |wa| "#{wa.workflow_step.workflow.name} > #{wa.workflow_step.workflow.name} > #{wa.name}" }.join('; ')))
      false
    else
      true
    end
  end

  def expire_cache_options
    { path: path }
  end

end
