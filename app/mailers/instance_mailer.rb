require 'mail_view'

class InstanceMailer < ActionMailer::Base
  prepend_view_path EmailResolver.instance

  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  def mail(options = {})
    lookup_context.class.register_detail(:instance) { nil }

    instance = options.delete(:instance)
    template = options.delete(:template_name) || view_context.action_name
    mailer = options.delete(:mailer) || find_mailer(template: template, instance: instance) || instance.default_mailer
    subject_locals = options.delete(:subject_locals)
    subject  = mailer.liquid_subject(subject_locals) || options.delete(:subject)

    self.class.layout _layout, instance: instance

    super(options.merge!(
      :subject => subject,
      :bcc     => mailer.bcc,
      :from    => mailer.from,
      :reply_to=> mailer.reply_to,
      :content_type => "multipart/alternative")) do |format|
        format.html { render template, instance: instance }
        format.text { render template, instance: instance }
      end
  end

  private

  def find_mailer(options = {})
    instance = options.delete(:instance)
    default_options = { template: view_context.action_name }
    options = default_options.merge!(options)

    details = {instance: instance, handlers: [:liquid], formats: [:html, :text]}
    template_name = options[:template]
    template_prefix = view_context.lookup_context.prefixes.first

    template = EmailResolver.instance.find_mailers(template_name, template_prefix, false, details).first

    return template
  end
end
