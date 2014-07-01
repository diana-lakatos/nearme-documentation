require 'email_resolver'

class EmailTemplate < ActiveRecord::Base
  belongs_to :theme
  # attr_accessible :handler, :html_body, :text_body, :path, :partial, :subject, :to, :from, :bcc, :reply_to, :subject

  CUSTOMIZABLE_EMAILS = %w(post_action_mailer/sign_up_welcome
                           post_action_mailer/sign_up_verify
                           post_action_mailer/created_by_instance_admin
                           post_action_mailer/list
                           post_action_mailer/list_draft
                           post_action_mailer/unsubscription
                           inquiry_mailer/inquiring_user_notification
                           inquiry_mailer/listing_creator_notification
                           listing_mailer/share
                           rating_mailer/request_rating_of_guest_from_host
                           rating_mailer/request_rating_of_host_from_guest
                           reengagement_mailer/no_bookings
                           reengagement_mailer/one_booking
                           recurring_mailer/analytics
                           recurring_mailer/request_photos
                           recurring_mailer/share
                           reservation_mailer/notify_guest_of_cancellation_by_guest
                           reservation_mailer/notify_guest_of_cancellation_by_host
                           reservation_mailer/notify_guest_of_confirmation
                           reservation_mailer/notify_guest_of_expiration
                           reservation_mailer/notify_guest_of_rejection
                           reservation_mailer/notify_guest_with_confirmation
                           reservation_mailer/notify_host_of_cancellation_by_guest
                           reservation_mailer/notify_host_of_cancellation_by_host
                           reservation_mailer/notify_host_of_confirmation
                           reservation_mailer/notify_host_of_expiration
                           reservation_mailer/notify_host_of_rejection
                           reservation_mailer/notify_host_with_confirmation
                           reservation_mailer/notify_host_without_confirmation
                           reservation_mailer/pre_booking)

  validates :html_body, :text_body, :path, :theme_id, presence: true
  validates_uniqueness_of :path, :scope => [:theme_id]
  validates_inclusion_of :path, :in => CUSTOMIZABLE_EMAILS

  after_save do
    EmailResolver.instance.clear_cache
  end

  def locale
    "en"
  end

  def handler
    "liquid"
  end

  def liquid_subject(locals = {})
    return if self.subject.to_s.empty?
    template = Liquid::Template.parse(self.subject)
    template.render(locals.stringify_keys!)
  end

  def self.new_from_file_template(path)
    if EmailTemplate::CUSTOMIZABLE_EMAILS.include?(path)
      text = File.read(File.join(Rails.root, 'app', 'views', path + '.text.liquid')) rescue nil
      html = File.read(File.join(Rails.root, 'app', 'views', path + '.html.liquid')) rescue nil
      subject = I18n.t(:subject, scope: path.gsub('/','.'), default: '')
      EmailTemplate.new(path: path, subject: subject, text_body: text, html_body: html)
    end
  end
end
