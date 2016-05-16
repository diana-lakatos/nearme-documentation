class InstanceMailer < ActionMailer::Base
  prepend_view_path InstanceViewResolver.instance
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  self.job_class = MailerJob
  attr_accessor :platform_context

  def mail(options = {})
    lookup_context.class.register_detail(:transactable_type_id) { nil }
    @platform_context = PlatformContext.current.decorate
    template = options.delete(:template_name) || view_context.action_name
    layout_path = options.delete(:layout_path)
    lookup_context.transactable_type_id = options.delete(:transactable_type_id)

    to = options[:to]
    bcc = options.delete(:bcc)
    cc = options.delete(:cc)
    from = options.delete(:from)
    subject  = options.delete(:subject)
    reply_to = options.delete(:reply_to)
    @user  = User.with_deleted.find_by_email(to.kind_of?(Array) ? to.first : to)
    @email_method = template
    custom_tracking_options  = (options.delete(:custom_tracking_options) || {}).reverse_merge({template: template, campaign: @email_method.split('/')[0].humanize})

    @mailer_signature = generate_signature
    @signature_for_tracking = "&email_signature=#{@mailer_signature}"

    track_sending_email(custom_tracking_options)
    self.class.layout _layout, platform_context: @platform_context, locale: I18n.locale
    render_options = { platform_context: @platform_context, locale: I18n.locale }
    render_options.merge!({layout: layout_path}) if layout_path.present?

    options.merge!(
      subject: subject,
      bcc: bcc,
      cc: cc,
      from: from,
      reply_to: reply_to
    )

    message = super(options) do |format|
      format.html { render(template, render_options) + get_tracking_code(custom_tracking_options).html_safe }
      format.text { render(template, render_options) rescue '' }
    end

    attachment_parts = []
    message.parts.each do |part|
      attachment_parts << message.parts.delete(part) if part.attachment? && !part.inline?
    end

    content_part = Mail::Part.new do
      content_type 'multipart/alternative'
      message.parts.delete_if { |part| add_part(part) }
    end

    message.content_type('multipart/mixed')
    message.header['content-type'].parameters[:boundary] = message.body.boundary

    message.add_part(content_part)
    attachment_parts.each { |part| message.add_part(part) }

    message
  end

  private

  def details_for_lookup
    {
      instance_id: PlatformContext.current.try(:instance).try(:id),
      i18n_locale: I18n.locale
    }
  end

  def get_tracking_code(custom_tracking_options)
    event_tracker.pixel_track_url("Email Opened", custom_tracking_options)
  end

  def event_tracker
    @mixpanel_wrapper ||= AnalyticWrapper::MixpanelApi.new(
      AnalyticWrapper::MixpanelApi.mixpanel_instance(),
      :current_user       => @user,
      :request_details    => { current_instance_id: @platform_context.instance.id }
    )
    @event_tracker ||= Rails.application.config.event_tracker.new(@mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(@user))
    @event_tracker
  end

  def track_sending_email(custom_tracking_options)
    event_tracker.email_sent(custom_tracking_options)
  end

  def generate_signature
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    verifier.generate(@email_method)
  end

end
