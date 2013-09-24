class InstanceMailer < ActionMailer::Base
  prepend_view_path EmailResolver.instance
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  self.job_class = MailerJob

  def mail(options = {})
    lookup_context.class.register_detail(:theme) { nil }

    theme = options.delete(:theme)
    template = options.delete(:template_name) || view_context.action_name
    mailer = options.delete(:mailer) || find_mailer(template: template, theme: theme) || theme.default_mailer
    subject_locals = options.delete(:subject_locals)
    subject  = mailer.liquid_subject(subject_locals) || options.delete(:subject)
    reply_to = options.delete(:reply_to) || mailer.reply_to

    self.class.layout _layout, theme: theme

    super(options.merge!(
      :subject => subject,
      :bcc     => mailer.bcc,
      :from    => mailer.from,
      :reply_to=> reply_to,
      :content_type => "multipart/alternative")) do |format|
        format.html { render template, theme: theme }
        format.text { render template, theme: theme }
      end
  end

  private

  def instance_prefix(text, instance)
    text.prepend "[#{instance.name}] " if instance
    text
  end

  def find_mailer(options = {})
    theme = options.delete(:theme)
    default_options = { template: view_context.action_name }
    options = default_options.merge!(options)

    details = {theme: theme, handlers: [:liquid], formats: [:html, :text]}
    template_name = options[:template]
    template_prefix = view_context.lookup_context.prefixes.first

    template = EmailResolver.instance.find_mailers(template_name, template_prefix, false, details).first

    return template
  end
end
