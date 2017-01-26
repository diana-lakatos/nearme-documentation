# frozen_string_literal: true
class InstanceView < ActiveRecord::Base
  include Cacheable

  has_paper_trail
  belongs_to :instance
  has_many :transactable_type_instance_views, dependent: :destroy
  has_many :transactable_types, through: :transactable_type_instance_views
  has_many :locale_instance_views, dependent: :destroy
  has_many :locales, through: :locale_instance_views

  VIEW_VIEW = 'view'
  CUSTOM_VIEW = 'custom_view'
  EMAIL_VIEW = 'email'
  SMS_VIEW = 'sms'
  EMAIL_LAYOUT_VIEW = 'mail_layout'
  VIEW_TYPES = [SMS_VIEW, EMAIL_VIEW, EMAIL_LAYOUT_VIEW, VIEW_VIEW, CUSTOM_VIEW].freeze

  DEFAULT_EMAIL_TEMPLATES_PATHS = [
    'activity_events_mailer/activity_events_summary',
    'company_mailer/notify_host_of_no_payout_option',
    'data_upload_mailer/notify_uploader_of_failed_import',
    'data_upload_mailer/notify_uploader_of_finished_import',
    'group_mailer/group_owner_added_member_email',
    'group_mailer/member_declined',
    'group_mailer/member_has_quit',
    'group_mailer/notify_members_of_new_member',
    'group_mailer/notify_members_of_new_member_in_public_group',
    'group_mailer/notify_user_of_approved_join_request',
    'group_mailer/pending_approval',
    'group_mailer/user_accepts_invitation',
    'inappropriate_reports_mailer/inappropriate_report',
    'listing_mailer/share',
    'offer_mailer/notify_guest_of_cancellation_by_guest',
    'offer_mailer/notify_guest_of_cancellation_by_host',
    'offer_mailer/notify_guest_of_confirmation',
    'offer_mailer/notify_guest_of_expiration',
    'offer_mailer/notify_guest_of_payment_request',
    'offer_mailer/notify_guest_of_penalty_charge_failed',
    'offer_mailer/notify_guest_of_penalty_charge_succeeded',
    'offer_mailer/notify_guest_of_rejection',
    'offer_mailer/notify_guest_of_shipping_details',
    'offer_mailer/notify_guest_of_submitted_checkout',
    'offer_mailer/notify_guest_of_submitted_checkout_with_failed_authorization',
    'offer_mailer/notify_guest_with_confirmation',
    'offer_mailer/notify_host_of_approved_payment',
    'offer_mailer/notify_host_of_cancellation_by_guest',
    'offer_mailer/notify_host_of_cancellation_by_host',
    'offer_mailer/notify_host_of_confirmation',
    'offer_mailer/notify_host_of_declined_payment',
    'offer_mailer/notify_host_of_expiration',
    'offer_mailer/notify_host_of_rejection',
    'offer_mailer/notify_host_of_shipping_details',
    'offer_mailer/notify_host_with_confirmation',
    'offer_mailer/notify_host_without_confirmation',
    'offer_mailer/pre_booking',
    'payment_gateway_mailer/notify_host_about_payout_failure_email',
    'payment_gateway_mailer/notify_host_of_merchant_account_approval',
    'payment_gateway_mailer/notify_host_of_merchant_account_declinal',
    'payment_gateway_mailer/notify_host_of_merchant_account_requirements',
    'payment_gateway_mailer/notify_enquirer_of_bank_account_creation',
    'payment_gateway_mailer/notify_enquirer_of_bank_account_verification',
    'post_action_mailer/created_by_instance_admin',
    'post_action_mailer/instance_created',
    'post_action_mailer/list',
    'post_action_mailer/list_draft',
    'post_action_mailer/sign_up_verify',
    'post_action_mailer/sign_up_welcome',
    'post_action_mailer/unsubscription',
    'post_action_mailer/user_created_invitation',
    'purchase_mailer/notify_guest_of_confirmation',
    'purchase_mailer/notify_host_of_confirmation',
    'purchase_mailer/notify_guest_of_rejection',
    'purchase_mailer/notify_host_of_rejection',
    'rating_mailer/request_rating_of_guest_from_host',
    'rating_mailer/request_rating_of_host_from_guest',
    'recurring_booking_mailer/notify_guest_of_cancellation_by_guest',
    'recurring_booking_mailer/notify_guest_of_cancellation_by_host',
    'recurring_booking_mailer/notify_guest_of_confirmation',
    'recurring_booking_mailer/notify_guest_of_expiration',
    'recurring_booking_mailer/notify_guest_of_payment_overdue',
    'recurring_booking_mailer/notify_guest_of_rejection',
    'recurring_booking_mailer/notify_guest_with_confirmation',
    'recurring_booking_mailer/notify_host_of_cancellation_by_guest',
    'recurring_booking_mailer/notify_host_of_cancellation_by_host',
    'recurring_booking_mailer/notify_host_of_confirmation',
    'recurring_booking_mailer/notify_host_of_expiration',
    'recurring_booking_mailer/notify_host_of_payment_information_updated',
    'recurring_booking_mailer/notify_host_of_payment_overdue',
    'recurring_booking_mailer/notify_host_of_rejection',
    'recurring_booking_mailer/notify_host_with_confirmation',
    'recurring_booking_mailer/notify_host_without_confirmation',
    'recurring_booking_mailer/pre_booking',
    'recurring_mailer/analytics',
    'recurring_mailer/request_photos',
    'recurring_mailer/share',
    'reengagement_mailer/no_bookings',
    'reengagement_mailer/one_booking',
    'reservation_mailer/notify_guest_of_cancellation_by_guest',
    'reservation_mailer/notify_guest_of_cancellation_by_host',
    'reservation_mailer/notify_guest_of_confirmation',
    'reservation_mailer/notify_guest_of_expiration',
    'reservation_mailer/notify_guest_of_payment_request',
    'reservation_mailer/notify_guest_of_penalty_charge_failed',
    'reservation_mailer/notify_guest_of_penalty_charge_succeeded',
    'reservation_mailer/notify_guest_of_rejection',
    'reservation_mailer/notify_guest_of_shipping_details',
    'reservation_mailer/notify_guest_of_submitted_checkout',
    'reservation_mailer/notify_guest_of_submitted_checkout_with_failed_authorization',
    'reservation_mailer/notify_guest_with_confirmation',
    'reservation_mailer/notify_host_of_approved_payment',
    'reservation_mailer/notify_host_of_cancellation_by_guest',
    'reservation_mailer/notify_host_of_cancellation_by_host',
    'reservation_mailer/notify_host_of_confirmation',
    'reservation_mailer/notify_host_of_declined_payment',
    'reservation_mailer/notify_host_of_expiration',
    'reservation_mailer/notify_host_of_rejection',
    'reservation_mailer/notify_host_of_shipping_details',
    'reservation_mailer/notify_host_with_confirmation',
    'reservation_mailer/notify_host_without_confirmation',
    'reservation_mailer/pre_booking',
    'reservation_mailer/warn_guest_of_expiration',
    'saved_search_mailer/notify_user_of_daily_results',
    'saved_search_mailer/notify_user_of_weekly_results',
    'spam_reports_mailer/summary',
    'support_mailer/request_received',
    'support_mailer/request_replied',
    'support_mailer/request_updated',
    'support_mailer/rfq_request_received',
    'support_mailer/rfq_request_replied',
    'support_mailer/rfq_request_updated',
    'support_mailer/rfq_support_received',
    'support_mailer/rfq_support_updated',
    'support_mailer/support_received',
    'support_mailer/support_updated',
    'transactable_mailer/collaborator_approved',
    'transactable_mailer/collaborator_declined',
    'transactable_mailer/collaborator_has_quit',
    'transactable_mailer/pending_approval',
    'transactable_mailer/transactable_owner_added_collaborator_email',
    'user_mailer/created_by_instance_admin',
    'user_mailer/notify_about_unread_messages',
    'user_mailer/notify_about_wrong_phone_number',
    'user_mailer/profile_approved',
    'user_mailer/user_commented_on_group',
    'user_mailer/user_commented_on_transactable',
    'user_mailer/user_commented_on_user_update',
    'user_mailer/user_followed_transactable',
    'user_mailer/user_followed_user',
    'user_mailer/user_promoted_to_instance_admin_email',
    'user_message_mailer/email_message_from_guest',
    'user_message_mailer/email_message_from_host',
    'vendor_approval_mailer/notify_admin_of_new_listings',
    'vendor_approval_mailer/notify_host_of_listing_approval',
    'vendor_approval_mailer/notify_host_of_listing_questioned',
    'vendor_approval_mailer/notify_host_of_listing_rejection',
    'vendor_approval_mailer/notify_host_of_user_approval'
  ].sort.freeze

  DEFAULT_SMS_TEMPLATES_PATHS = [
    'company_sms_notifier/notify_host_of_no_payout_option',
    'recurring_booking_sms_notifier/notify_guest_with_state_change',
    'recurring_booking_sms_notifier/notify_host_with_confirmation',
    'reservation_sms_notifier/notify_guest_with_state_change',
    'reservation_sms_notifier/notify_host_with_confirmation',
    'user_message_sms_notifier/notify_user_about_new_message'

  ].sort.freeze

  DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS = ['layouts/mailer'].sort.freeze

  # Contains documentation to be parsed by the documentation parser
  # Please keep it up-to-date when adding/modifying new liquid views to
  # this array.
  DEFAULT_LIQUID_VIEWS_PATHS = {
    'listings/show' => {
      listing: 'TransactableDrop'
    },
    'listings/booking_module_injection' => {
      listing: 'TransactableDrop'
    },
    'listings/social_buttons' => {
      listing: 'TransactableDrop'
    },
    'listings/booking_module_listing_description' => {
      listing: 'TransactableDrop'
    },
    'listings/location_description' => {
      location: 'LocationDrop'
    },
    'listings/listing_description' => {
      listing: 'TransactableDrop'
    },
    'listings/booking_module_call_to_actions' => {
      listing: 'TransactableDrop',
      book_hash: 'booking information array',
      rfq_class: 'string',
      rfq_label: 'string'
    },
    'listings/booking_module_listing_description_below_dates' => {
      listing: 'TransactableDrop'
    },
    'listings/booking_module_listing_description_below_call_to_action' => {
      listing: 'TransactableDrop'
    },
    'listings/booking_module_listing_description_above_call_to_action' => {
      listing: 'TransactableDrop'
    },
    'registrations/profile/user_badge' => {
      user: 'UserDrop',
      is_current_user: 'boolean; true if logged in user is viewing user',
      company: 'CompanyDrop'
    },
    'registrations/profile/header' => {
      user: 'UserDrop',
      is_current_user: 'boolean; true if logged in user is viewing user',
      company: 'CompanyDrop'
    },
    'listings/google_map' => {
      location: 'LocationDrop'
    },
    'listings/administrator' => {
      administrator: 'UserDrop',
      listing: 'TransactableDrop'
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
    'search/list/search_filters_boxes' => {
      listing: 'TransactableDrop',
      current_user: 'UserDrop'
    },
    'search/list/listing' => {
      listing: 'TransactableDrop',
      current_user: 'UserDrop'
    },
    'search/list/user' => {
      user: 'UserDrop',
      current_user: 'UserDrop'
    },
    'search/footer' => {
      transactable_type: 'TransactableTypeDrop',
      searcher: 'The search results for this page'
    },
    'reservation_mailer/social_links' => {
      listing: 'TransactableDrop'
    },
    'support_mailer/rfq_review' => {
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
    'registrations/tos_form' => {
      user: 'UserDrop',
      error: 'String',
      checked: 'Boolean',
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyer_header' => {
      platform_context: 'PlatformContextDrop'
    },
    'registrations/seller_header' => {
      platform_context: 'PlatformContextDrop'
    },
    'registrations/default_header' => {
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyer_footer' => {
      platform_context: 'PlatformContextDrop'
    },
    'registrations/seller_footer' => {
      platform_context: 'PlatformContextDrop'
    },
    'registrations/default_footer' => {
      platform_context: 'PlatformContextDrop'
    },
    'registrations/buyers/profile/tabs/blog_posts' => {
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
      is_partial: false
    },
    'registrations/profile/no_content' => {
      tab: 'String',
      user: 'UserDrop',
      is_partial: true
    },
    'registrations/profile/tabs/blog_posts' => {
      post: 'UserBlogPostDrop',
      user: 'UserDrop',
      is_partial: true
    },
    'registrations/profile/tabs/reviews' => {
      is_partial: true,
      user: 'UserDrop'
    },
    'registrations/profile/tabs/services' => {
      listings: 'Array',
      is_partial: true
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
    'listings/reservations/summary' => {
      reservation: 'ReservationDrop',
      reservation_request: 'ReservationRequestDrop'
    },
    'registrations/profile/tabs/transactable' => {
      'transactable': 'TransactableDrop',
      is_partial: true
    },
    'registrations/profile/tabs/general' => {
      user: 'UserDrop',
      is_current_user: 'boolean; true if logged in user is viewing user',
      company: 'CompanyDrop',
      is_partial: true
    },
    'home/index' => {
      is_partial: false
    },
    'home/search_box' => {
    },
    'home/search_button' => {
    },
    'home/search_box_inputs' => {
    },
    'home/homepage_content' => {
    },
    'layouts/theme_footer' => {
    },
    'layouts/theme_header' => {
    },
    'dashboard/company/host_reservations/reservation_completed' => {
      is_partial: false
    },
    'dashboard/company/host_reservations/complete_reservation_top' => {
      is_partial: false
    },
    'dashboard/user_messages/form' => {
      is_partial: true,
      '@user_message' => 'UserMessageDrop',
      '@error' => 'string'
    },
    'dashboard/reviews/order_info' => {
      is_partial: true,
      feedback: 'Polymorphic object',
      view_order_link: 'string',
      'link_to_user_profile': 'string',
      feedback_type: 'string'
    },
    'dashboard/reviews/review_image' => {
      is_partial: true,
      order_image: 'string',
      review_target_image: 'string',
      feedback: 'Polymorphic object',
      feedback_type: 'string'
    },
    'dashboard/reviews/review_title' => {
      is_partial: true,
      review_title: 'string',
      review_target_title: 'string',
      feedback: 'Polymorphic object',
      feedback_type: 'string'
    },
    'dashboard/reviews/rating_answer' => {
      is_partial: true,
      score: 'number'
    },
    'dashboard/reviews/rating_question' => {
      is_partial: true
    },
    'dashboard/reviews/overall_rating' => {
      is_partial: true,
      score: 'number',
      hints: 'string'
    },
    'dashboard/user_reservations/reservation_details' => {
      is_partial: true,
      reservation: 'ReservationDrop'
    },
    'dashboard/company/host_reservations/client_info_area' => {
      is_partial: true,
      reservation: 'ReservationDrop'
    },

    'checkout/summary' => {
      is_partial: true,
      order: 'OrderDrop'
    },
    'checkout/sidebar' => {
      is_partial: true,
      order: 'OrderDrop'
    },
    'home/search/datepickers' => {
      is_partial: true
    },
    'search/shared/date_range' => {
      is_partial: true,
      date_start: 'string',
      date_end: 'string'
    },
    'dashboard/offers/offer' => {
      is_partial: true,
      offer: 'OfferDrop'
    },
    'errors/not_found' => {
      is_partial: false
    },
    'errors/server_error' => {
      is_partial: false
    },
    'shared/social_meta_for_object' => {
      is_partial: true
    },
    'dashboard/user_messages/dashboard_form' => {
      is_partial: true
    }

  }.sort.to_h.freeze

  scope :for_instance_id, lambda { |instance_id|
    where('(instance_views.instance_id IS NULL OR instance_views.instance_id = ?)', instance_id)
  }

  scope :for_transactable_type_id, lambda { |id|
    joins(:transactable_type_instance_views).where(transactable_type_instance_views: { transactable_type_id: id })
  }

  scope :for_locale, lambda { |locale|
    joins(locale_instance_views: :locale).where(locales: { code: locale })
  }

  scope :liquid_views, lambda {
    custom_views.where(handler: 'liquid').order('path')
  }

  scope :custom_views, lambda {
    where(view_type: VIEW_VIEW).order('path')
  }

  scope :custom_theme_views, lambda {
    where(view_type: CUSTOM_VIEW)
  }

  scope :custom_smses, lambda {
    where(view_type: SMS_VIEW, format: 'text', handler: 'liquid').order('path')
  }

  scope :custom_emails, lambda {
    where(view_type: EMAIL_VIEW, format: %w(text html), handler: 'liquid').order('path')
  }

  scope :custom_email_layouts, lambda {
    where(view_type: EMAIL_LAYOUT_VIEW, format: %w(text html), handler: 'liquid').order('path')
  }

  def self.all_email_templates_paths
    (DEFAULT_EMAIL_TEMPLATES_PATHS + for_instance_id(PlatformContext.current.instance.id).custom_emails.pluck(:path)).uniq
  end

  def self.not_customized_sms_templates_paths
    DEFAULT_SMS_TEMPLATES_PATHS - for_instance_id(PlatformContext.current.instance.id).custom_smses.pluck(:path)
  end

  def self.not_customized_liquid_views_paths
    DEFAULT_LIQUID_VIEWS_PATHS.keys - for_instance_id(PlatformContext.current.instance.id).liquid_views.pluck(:path)
  end

  def self.not_customized_email_templates_paths
    custom_paths = for_instance_id(PlatformContext.current.instance.id).custom_emails.pluck(:path, :format).each_with_object({}) do |arr, hash|
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
    (DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS + for_instance_id(PlatformContext.current.instance.id).custom_email_layouts.pluck(:path)).uniq
  end

  def self.all_sms_template_layouts_paths
    (DEFAULT_SMS_TEMPLATES_PATHS + for_instance_id(PlatformContext.current.instance.id).custom_smses.pluck(:path)).uniq
  end

  def self.not_customized_email_template_layouts_paths
    custom_paths = for_instance_id(PlatformContext.current.instance.id).custom_email_layouts.pluck(:path, :format).each_with_object({}) do |arr, hash|
      hash[arr[0]] ||= []
      hash[arr[0]] << arr[1]
      hash
    end

    DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS.each do |path|
      custom_paths[path] ||= []
    end
    custom_paths
  end

  validates :body, presence: true
  validates :path, presence: true

  validates :locales, length: { minimum: 1 }
  validates :handler, inclusion: { in: ActionView::Template::Handlers.extensions.map(&:to_s) }
  validates :format, inclusion: { in: Mime::SET.symbols.map(&:to_s) }

  validate :does_not_duplicate_locale_and_transactable_type

  def does_not_duplicate_locale_and_transactable_type
    if (ids = InstanceView.distinct.where.not(id: id).where(instance_id: instance_id, path: path, partial: partial, view_type: view_type, format: format, custom_theme_id: custom_theme_id).for_locale(locales.map(&:code)).for_transactable_type_id(transactable_types.map(&:id)).pluck(:id)).present?
      ids = ids.join(', ')
      locales_names = Locale.distinct.where(id: locale_ids).joins(:locale_instance_views).where(locale_instance_views: { instance_view: ids }).map(&:name).join(', ')
      transactable_type_names = TransactableType.distinct.where(id: transactable_type_ids).joins(:transactable_type_instance_views).where(transactable_type_instance_views: { instance_view_id: ids }).pluck(:name).join(', ')
      errors.add(:locales, I18n.t('activerecord.errors.models.instance_view.attributes.locales_and_transactable_types.already_exists', ids: ids, locales: locales_names, transactable_types: transactable_type_names))
    end
  end

  def expire_cache_options
    { path: path }
  end

  def jsonapi_serializer_class_name
    'InstanceViewJsonSerializer'
  end
end
