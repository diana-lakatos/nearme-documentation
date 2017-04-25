# frozen_string_literal: true
class CustomAttachmentsController < ApplicationController
  def show
    attachment = CustomAttachment.find(params[:id])
    if accessible_to?(attachment, current_user)
      redirect_to attachment.file.url
    else
      redirect_to root_url, notice: "You're not allowed to access this file"
    end
  end

  private

  def accessible_to?(attachment, user)
    user && attachment.instance_id == user.instance_id
  end
end
