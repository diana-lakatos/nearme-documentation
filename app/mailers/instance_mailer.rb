# frozen_string_literal: true
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
    # do not change name of this var :) if you change it to @user, it will overwrite variables set by workflow step :)
    @user_to_which_email_will_be_sent = User.with_deleted.find_by(email: Array(to).first)

    @email_method = template
    @unsubscribe_url = generate_unsubscribe_url(options)

    self.class.layout _layout, platform_context: @platform_context, locale: I18n.locale
    render_options = { platform_context: @platform_context, locale: I18n.locale }
    render_options[:layout] = layout_path if layout_path.present?

    options.merge!(
      subject: subject,
      bcc: bcc,
      cc: cc,
      from: from,
      reply_to: reply_to
    )

    message = super(options) do |format|
      format.html { render(template, render_options) }
      format.text do
        begin
          render(template, render_options)
        rescue ::ActionView::MissingTemplate
          # do not require text format, html is enough
          ''
        end
      end
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

  def generate_unsubscribe_url(options)
    if options.values_at(:to, :cc, :bcc).compact.flatten.size == 1 && @user_to_which_email_will_be_sent.present?
      UserDrop.new(@user_to_which_email_will_be_sent).unsubscribe_url
    else
      @platform_context.unsubscribe_url
    end
  end
end
