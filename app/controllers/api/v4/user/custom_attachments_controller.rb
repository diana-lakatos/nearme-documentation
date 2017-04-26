# frozen_string_literal: true
module Api
  class V4::User::CustomAttachmentsController < Api::V4::User::BaseController
    def show
      attachment = CustomAttachment.find(params[:id])
      if accessible_to?(attachment, current_user)
        redirect_to attachment.file.url
      else
        redirect_to root_url, notice: I18n.t('flash.api.v4.custom_attachment.show.notice')
      end
    end

    def destroy
      custom_attachment = current_user.custom_attachments.find(params[:id])
      custom_attachment.destroy
      render nothing: true
    end

    private

    def accessible_to?(attachment, user)
      user && attachment.instance_id == user.instance_id
    end
  end
end
