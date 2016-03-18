class Webhooks::CommunicationsController < Webhooks::BaseController

  def status
    if params[:VerificationStatus].eql?('success')
      communication = Communication.find_by(request_key: params[:CallSid])

      if communication.present?
        communication.update_columns(
          phone_number_key: params[:OutgoingCallerIdSid],
          verified: true
        )
      end
    end

    head :ok
  end

end
