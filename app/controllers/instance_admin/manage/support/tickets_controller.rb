class InstanceAdmin::Manage::Support::TicketsController < InstanceAdmin::Manage::BaseController
  before_filter :find_ticket

  def show
    @first_message = @ticket.first_message
    @message = Support::TicketMessage.new
    @admins = InstanceAdmin.scoped.includes(:user).collect(&:user)
  end

  def update
    admin = InstanceAdmin.where(user_id: params[:assigned_to_id]).first
    @ticket.assign_to!(admin.try(:user))
    head 204
  end

  private

  def find_ticket
    @ticket = Support::Ticket.find(params[:id])
  end

  def permitting_controller_class
    'support'
  end
end
