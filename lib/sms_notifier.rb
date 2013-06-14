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
#         :to => reservation.listing_owner.formatted_mobile_number
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
  require 'sms_notifier/message'

  include AbstractController::Logger
  include AbstractController::Rendering
  include AbstractController::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers

  layout false
  self.asset_host = ActionController::Base.asset_host

  class_attribute :default_params
  self.default_params = {
    :from => nil # Set the default from number
  }

  class << self
    def method_missing(notification_name, *args)
      new(notification_name).send(notification_name, *args)
    end
  end

  def initialize(message_name)
    super()
    prepend_view_path 'app/views'
    @message_name = message_name
  end

  private

  # Build the SMS Message to send
  def sms(options)
    options = options.reverse_merge(self.class.default_params)
    options[:body] ||= render_message

    Message.new(options)
  end

  # Render the correct template with instance variables and
  # return the rendered template as a string.
  def render_message
    render :template => "#{notifier_name}/#{@message_name}"
  end

  def notifier_name
    self.class.name.underscore
  end

end
