class InstanceView < ActiveRecord::Base
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
    'rating_mailer/line_items/request_rating_of_guest_from_host', 'rating_mailer/line_items/request_rating_of_host_and_product_from_guest'
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

  scope :for_instance_type_id, ->(instance_type_id) {
    where('instance_type_id IS NULL OR instance_type_id = ?', instance_type_id)
  }

  scope :for_instance_id, ->(instance_id) {
    where('instance_id IS NULL OR instance_id = ?', instance_id)
  }

  scope :for_nil_transactable_type, ->  { where('transactable_type_id IS NULL') }


  scope :for_transactable_type_id, -> (transactable_type_id) {
    where('transactable_type_id IS NULL OR transactable_type_id = ?', transactable_type_id)
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

  def self.not_customized_sms_templates_paths
    DEFAULT_SMS_TEMPLATES_PATHS - self.for_instance_id(PlatformContext.current.instance.id).custom_smses.pluck(:path)
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
  validates_uniqueness_of :path, { scope: [:instance_id, :transactable_type_id, :transactable_type_id, :locale, :format, :handler] }

  before_validation do
    self.locale ||= 'en'
  end

end
