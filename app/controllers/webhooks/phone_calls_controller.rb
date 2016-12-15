# frozen_string_literal: true
class Webhooks::PhoneCallsController < Webhooks::BaseController
  def connect
    phone_call = PhoneCall.find_by(phone_call_key: params[:CallSid])

    response = Twilio::TwiML::Response.new do |r|
      r.Play PlatformContext.current.instance.twilio_ring_tone.presence || 'http://howtodocs.s3.amazonaws.com/howdy-tng.mp3'
      r.Dial phone_call.try(:to)
    end

    render text: response.text
  end

  def status
    render text: params[:CallStatus]
  end
end
