class PrepareEmail
  def self.available_mails
    files = Dir.glob(Rails.root.join('test', 'assets', 'mail_views', '**', '*.html.liquid').to_s)
    files.collect do |file|
      file.gsub!(Rails.root.join('test', 'assets', 'mail_views').to_s + '/', '')
      file.split('.html.liquid').first
    end
  end

  def self.for(virtual_path, attributes = {})
    prefix, name = virtual_path.split('/')

    html_path = Rails.root.join('test', 'assets', 'mail_views', prefix, "#{name}.html.liquid")
    text_path = Rails.root.join('test', 'assets', 'mail_views', prefix, "#{name}.text.liquid")

    raise "No email template fixture exists in test/assets/#{html_path}" unless File.exists?(html_path)
    raise "No email template fixture exists in test/assets/#{text_path}" unless File.exists?(text_path)

    html_template = File.read(html_path)
    text_template = File.read(text_path)

    FactoryGirl.create(:email_template, {html_body: html_template, text_body: text_template, path: virtual_path, instance: Instance.default_instance || FactoryGirl.create(:instance)}.merge(attributes))
  end

  def self.import_legacy
    self.available_mails.each do |path|
      PrepareEmail.for(path, ATTRIBUTES[path] || {})
    end
  end

  ATTRIBUTES = {
    'after_signup_mailer/user_with_booking' => {
      from: 'micheller@desksnear.me',
      reply_to: 'micheller@desksnear.me',
      subject: 'Welcome to DesksNear.me'
    },
    'after_signup_mailer/user_with_listing' => {
      from: 'micheller@desksnear.me',
      reply_to: 'micheller@desksnear.me',
      subject: 'Welcome to DesksNear.me'
    },
    'after_signup_mailer/user_without_listing_and_booking' => {
      from: 'micheller@desksnear.me',
      reply_to: 'micheller@desksnear.me',
      subject: 'Welcome to DesksNear.me'
    },
    'inquiry_mailer/inquiring_user_notification' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: "We've passed on your inquiry about {{inquiry.listing.name}}"
    },
    'inquiry_mailer/listing_creator_notification' => {
      from: 'support@desksnear.me',
      subject: "New enquiry from {{inquiry.inquiring_user.name}} about {{inquiry.listing.name}}"
    },
    'listing_mailer/share' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: "{{sharer.name}} has shared a listing with you on Desks Near Me"
    },
    'reservation_mailer/notify_guest_of_cancellation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking you made has been cancelled by the owner'
    },
    'reservation_mailer/notify_guest_of_confirmation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking you made has been confirmed'
    },
    'reservation_mailer/notify_guest_of_rejection' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking you made has been rejected'
    },
    'reservation_mailer/notify_guest_with_confirmation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking you made is pending confirmation'
    },
    'reservation_mailer/notify_host_of_cancellation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A guest has cancelled a booking'
    },
    'reservation_mailer/notify_host_of_confirmation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'You have confirmed a booking'
    },
    'reservation_mailer/notify_guest_of_expiration' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking you made has expired'
    },
    'reservation_mailer/notify_host_of_expiration' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking for one of your listings has expired'
    },
    'reservation_mailer/notify_host_with_confirmation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A booking requires your confirmation"'
    },
    'reservation_mailer/notify_host_without_confirmation' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: 'A guest has made a booking'
    },
    'user_mailer/notify_about_wrong_phone_number' => {
      from: 'support@desksnear.me',
      reply_to: 'support@desksnear.me',
      subject: "[Desks Near Me] We couldn't send you text message"
    },
    'user_mailer/email_verification' => {
      from: 'support@desksnear.me',
      subject: "Email verification"
    },

  }
end
