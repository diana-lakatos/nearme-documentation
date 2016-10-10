class ApprovalRequestAttachmentsController < ApplicationController
  before_action :check_for_xhr

  before_action :check_user_present, only: :create

  def create
    template = ApprovalRequestAttachmentTemplate.find(params[:approval_request_attachment_template_id])

    @attachment = ApprovalRequestAttachment.new(
      file: params[:file],
      uploader_id: current_user.id,
      approval_request_attachment_template_id: template.id,
      label:    template.label,
      hint:     template.hint,
      required: template.required
    )

    if @attachment.save
      render partial: 'dashboard/shared/attachments/approval_request_attachment', locals: { attachment: @attachment }
    else
      render partial: 'dashboard/shared/errors', locals: { errors: @attachment.errors.full_messages.join(', ') }
    end
  end

  def destroy
    @attachment = current_user.approval_request_attachments.find(params[:id])
    @attachment.destroy
    render nothing: true
  end

  private

  def check_user_present
    render partial: 'approval_requests/failed_attachment' if current_user.blank?
  end

  def check_for_xhr
    fail ActionController::MethodNotAllowed unless request.xhr?
  end
end
