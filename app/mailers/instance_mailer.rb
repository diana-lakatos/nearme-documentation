class InstanceMailer < ActionMailer::Base
  prepend_view_path EmailResolver.instance
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  self.job_class = MailerJob

  def mail(options = {})
    lookup_context.class.register_detail(:instance) { nil }

    instance = options.delete(:instance)
    template = options.delete(:template_name) || view_context.action_name
    mailer = options.delete(:mailer) || find_mailer(template: template, instance: instance) || instance.default_mailer
    subject_locals = options.delete(:subject_locals)
    subject  = mailer.liquid_subject(subject_locals) || options.delete(:subject)
    reply_to = options.delete(:reply_to) || mailer.reply_to

    self.class.layout _layout, instance: instance

    mixed = super(options.merge!(
      :subject => subject,
      :bcc     => mailer.bcc,
      :from    => mailer.from,
      :reply_to=> reply_to)) do |format|
        format.html { render template, instance: instance }
        format.text { render template, instance: instance }
      end

    mixed.add_part(
      Mail::Part.new do
        content_type 'multipart/alternative'
        mixed.parts.reverse!.delete_if {|p| add_part p }
      end
    )

    mixed.content_type 'multipart/mixed'
    mixed.header['content-type'].parameters[:boundary] = mixed.body.boundary
  end

  private

  def instance_prefix(text, instance)
    text.prepend "[#{instance.name}] " if instance
    text
  end

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
