# frozen_string_literal: true
class Payment::Gateway::Response::Stripe::Event
  delegate :id, :api_version,  :data, :type, :[], to: :@event_object

  def initialize(event_object)
    @event_object = event_object
  end

  def webhook_external_id
    [id, user_id].join('/')
  end

  def livemode?
    @event_object.livemode
  end

  def user_id
    if version >= '2017-05-25'
      @event_object.account
    else
      @event_object.user_id
    end
  end

  def version
    Payment::Gateway::Response::Stripe::Version.new(api_version)
  end
end
