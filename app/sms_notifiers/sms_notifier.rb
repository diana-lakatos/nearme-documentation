# Base class for our SMS notifiers
#
# The interface is deliberately designed to be similar to that
# of ActionMailer.
#
# Usage:
#
#   class ReservationsSmsNotifier < SmsNotifier
#     def received_reservation(reservation)
#       @reservation = reservation
#
#       sms(
#         :to => reservation.transactable_owner.formatted_mobile_number
#       )
#     end
#   end
#
#   # app/views/listing_sms_notifier/received_reservation.txt.erb
#   You have received a booking request on Desks Near Me.
#   Please confirm or decline from your dashboard: <%= sms_short_url(manage_reservation_url(@reservation)) %>
#
#   # ReservationsController
#   def create
#     # ...
#     ReservatonMailer.received_reservation(@reservation).deliver
#     ReservationSmsNotifier.received_reservation(@reservation).deliver
#   end
class SmsNotifier < AbstractController::Base
  extend Job::SyntaxEnhancer
  include AbstractController::Logger
  include AbstractController::Rendering
  include ActionView::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths

  layout false

  class << self
    def method_missing(notification_name, *args)
      new(notification_name, *args).message
    end
  end

  class NullMessage
    attr_reader :to, :from, :body
    def initialize(*)
    end

    def deliver
      false
    end
    alias_method :deliver!, :deliver
  end

  def initialize(message_name = nil, *args)
    super()
    @message_name = message_name
    process(@message_name, *args)
  end

  def message
    @message || NullMessage.new
  end

  def platform_context
    PlatformContext.current
  end

  private

  # Build the SMS Message to send
  def sms(options)
    @platform_context = PlatformContext.current.decorate
    if options.fetch(:content, nil)
      options[:body] ||= options.delete(:content)
    else
      lookup_context.class.register_detail(:transactable_type_id) { nil }
      @template_path = options.fetch(:template_name, nil)
      @transactable_type_id = options.fetch(:transactable_type_id, nil)
      options[:body] ||= render_message.try(:strip)
    end
    @message = Message.new(options)
  end

  # Render the correct template with instance variables and
  # return the rendered template as a string.
  def render_message
    lookup_context.transactable_type_id = @transactable_type_id
    rendered_message = render(template: template_path, formats: [:text], handlers: [:liquid], locale: I18n.locale)
    # We call .to_str to avoid a bug where unescapeHTML crashes when processing an ActiveSupport::SafeBuffer
    CGI::unescapeHTML(rendered_message.to_str)
  end

  def template_path
    @template_path || "#{notifier_name}/#{@message_name}"
  end

  def notifier_name
    self.class.name.underscore
  end
end
