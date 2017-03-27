# frozen_string_literal: true
module Api
  class V4::User::CustomAttachmentsController < Api::V4::User::BaseController
    def destroy
      custom_attachment = current_user.custom_attachments.find(params[:id])
      custom_attachment.destroy
      render nothing: true
    end
  end
end
