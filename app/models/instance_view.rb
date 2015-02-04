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

  validates_presence_of :body
  validates_presence_of :path
  validates_inclusion_of :locale, in: I18n.available_locales.map(&:to_s)
  validates_inclusion_of :handler, in: ActionView::Template::Handlers.extensions.map(&:to_s)
  validates_inclusion_of :format, in: Mime::SET.symbols.map(&:to_s)

  before_validation do
    self.locale ||= 'en'
  end

end
