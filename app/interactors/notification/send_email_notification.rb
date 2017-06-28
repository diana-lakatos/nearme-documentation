# frozen_string_literal: true
module Notification
  class SendEmailNotification < SendNotification
    protected

    def send
      InstanceMailer.mail(options).deliver
    end

    private

    def options
      @options ||= {
        to: array_of_emails_respecting_unsubscription(:to),
        subject: liquify(@notification.subject),
        content: liquify(@notification.content),
        layout_path: @notification.layout_path,
        from: @notification.from,
        reply_to: @notification.reply_to,
        cc: array_of_emails_respecting_unsubscription(:cc),
        bcc: array_of_emails_respecting_unsubscription(:bcc)
      }
    end

    def array_of_emails_respecting_unsubscription(field)
      apply_unsubscription(arraify(liquify(@notification.public_send(field))))
    end

    def arraify(value)
      value.split(',').reject(&:blank?).map(&:strip)
    end

    def mandatory_fields
      %i(to subject content from)
    end

    def apply_unsubscription(emails)
      filtered_emails ||= unsubscribed_emails(emails)
      return emails if filtered_emails.empty?
      emails.reject { |e| filtered_emails.include?(e.downcase) }
    end

    def unsubscribed_emails(emails)
      User.with_deleted.with_emails(emails).where(accept_emails: false).pluck('lower(email)')
    end
  end
end
