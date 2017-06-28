# frozen_string_literal: true
class InstanceMailer < ActionMailer::Base
  prepend_view_path InstanceViewResolver.instance
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  self.job_class = MailerJob
  attr_accessor :platform_context

  def mail(to:, from:, subject:, bcc: [], cc: [], reply_to: nil, **options)
    lookup_context.class.register_detail(:transactable_type_id) { nil }
    @platform_context = PlatformContext.current&.decorate

    inline_content = options.delete(:content)
    template = options.delete(:template_name) || view_context.action_name
    layout_path = options.delete(:layout_path)
    lookup_context.transactable_type_id = options.delete(:transactable_type_id)

    # do not change name of this var :) if you change it to @user, it will overwrite variables set by workflow step :)
    @user_to_which_email_will_be_sent = User.with_deleted.find_by(email: Array(to).first)

    @email_method = template
    @unsubscribe_url = generate_unsubscribe_url(options)

    self.class.layout _layout, platform_context: @platform_context, locale: I18n.locale
    render_options = { platform_context: @platform_context, locale: I18n.locale }
    render_options[:layout] = layout_path if layout_path.present?

    options.merge!(
      to: to,
      from: from,
      subject: subject,
      bcc: bcc,
      cc: cc,
      reply_to: reply_to
    )

    message = if inline_content.present?
                super(options) do |format|
                  format.html { render render_options.merge(inline: inline_content) }
                  format.text { '' }
                end
              else
                super(options) do |format|
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
      return '' if @platform_context.nil?
      PlatformContextDrop.new(@platform_context).unsubscribe_url
    end
  end
end
