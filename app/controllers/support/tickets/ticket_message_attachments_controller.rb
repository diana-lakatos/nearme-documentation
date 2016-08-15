class Support::Tickets::TicketMessageAttachmentsController < Support::BaseController
  before_action :ensure_user_logged_in
  before_action :find_ticket
  before_action :set_form_name, only: [:create, :update, :edit]

  def edit
    @ticket_message_attachment = @ticket.attachments.find(params[:id])
    render template: 'support/ticket_message_attachments/edit'
  end

  def create
    @ticket_message_attachment = @ticket.attachments.build(attachment_params)
    @ticket_message_attachment.file_type = @ticket_message_attachment.file.try(:content_type)
    @ticket_message_attachment.uploader = current_user
    @ticket_message_attachment.tag = Support::TicketMessageAttachment::TAGS.first
    if @ticket_message_attachment.save
      flash.now[:success] = t('flash_messages.support.ticket_message_attachment.created')
      render json: {
        attachment_content: render_to_string(partial: 'support/ticket_message_attachments/attachment', locals: {form_name: @form_name, ticket_message_attachment: @ticket_message_attachment}),
        modal_content: render_to_string(template: 'support/ticket_message_attachments/edit')
      }
    else
      render nothing: true, status: 422
    end
  end

  def update
    @ticket_message_attachment = @ticket.attachments.where(uploader_id: current_user.id, ticket_message_id: nil).find(params[:id])
    @ticket_message_attachment.assign_attributes(attachment_params)
    if @ticket_message_attachment.save
      render json: {
        attachment_content: render_to_string(partial: 'support/ticket_message_attachments/attachment', locals: {form_name: @form_name, ticket_message_attachment: @ticket_message_attachment}),
        attachment_id: @ticket_message_attachment.id
      }
    else
      render template: 'support/ticket_message_attachments/edit'
    end
  end

  def destroy
    @ticket_message_attachment = @ticket.attachments.where(uploader_id: current_user.id, ticket_message_id: nil).find(params[:id])
    @ticket_message_attachment.destroy
    render nothing: true, status: 200
  end

  private

  def ensure_user_logged_in
    if (request.xhr? && current_user.blank?)
      render json: { error_message: I18n.t('general.session_stale') }, status: 503
    end
    true
  end

  def find_ticket
    @ticket = if current_user.instance_admin?
                Support::Ticket.find(params[:ticket_id])
              else
                current_user.tickets.find_by_id(params[:ticket_id]) || current_user.assigned_tickets.find(params[:ticket_id])
              end
  end

  def attachment_params
    params.require(:support_ticket_message_attachment).permit(secured_params.support_ticket_message_attachment)
  end

  def set_form_name
    @form_name = params.delete(:form_name).presence || params.delete(:formName)
  end
end

