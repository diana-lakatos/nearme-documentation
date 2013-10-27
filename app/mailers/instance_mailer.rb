class InstanceMailer < ActionMailer::Base
  prepend_view_path EmailResolver.instance
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  self.job_class = MailerJob

  def mail(options = {})
    lookup_context.class.register_detail(:platform_context) { nil }

    platform_context = options.delete(:platform_context)
    template = options.delete(:template_name) || view_context.action_name
    mailer = options.delete(:mailer) || find_mailer(template: template, platform_context: platform_context) || platform_context.theme.default_mailer
    to = options[:to]
    bcc = options.delete(:bcc) || mailer.bcc
    from = options.delete(:from) || mailer.from
    subject_locals = options.delete(:subject_locals)
    subject  = mailer.liquid_subject(subject_locals) || options.delete(:subject)
    reply_to = options.delete(:reply_to) || mailer.reply_to
    user  = User.find_by_email(to.kind_of?(Array) ? to.first : to)
    email_method = StackTraceParser.new(caller[0]).humanized_method_name
    custom_tracking_options  = (options.delete(:custom_tracking_options) || {}).reverse_merge({template: template, campaign: email_method})

    self.class.layout _layout, platform_context: platform_context

    mixed = super(options.merge!(
      :subject => subject,
      :bcc     => bcc,
      :from    => from,
      :reply_to=> reply_to)) do |format|
        format.html { render(template, platform_context: platform_context.decorate) + get_tracking_code(user, platform_context, custom_tracking_options).html_safe }
        format.text { render template, platform_context: platform_context.decorate }
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

  def instance_prefix(text, platform_context_decorator)
    text.prepend "[#{platform_context_decorator.name}] "
    text
  end

  def find_mailer(options = {})
    platform_context = options.delete(:platform_context)
    default_options = { template: view_context.action_name }
    options = default_options.merge!(options)

    details = {platform_context: [platform_context], handlers: [:liquid], formats: [:html, :text]}
    template_name = options[:template]
    template_prefix = view_context.lookup_context.prefixes.first

    template = EmailResolver.instance.find_mailers(template_name, template_prefix, false, details).first

    return template
  end

  def get_tracking_code(user, platform_context, custom_tracking_options)
    @mixpanel_wrapper ||= AnalyticWrapper::MixpanelApi.new(
      AnalyticWrapper::MixpanelApi.mixpanel_instance(),
      :current_user       => user,
      :request_details    => { :current_instance_id => platform_context.instance.id }
    )
    @event_tracker ||= Analytics::EventTracker.new(@mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(user))
    @event_tracker.pixel_track_url("Email Opened", custom_tracking_options)
  end
end
