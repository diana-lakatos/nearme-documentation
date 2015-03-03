class BuySellMarket::Support::TicketsController < ApplicationController
  before_filter :find_product
  before_filter :force_log_in

  def new
    @ticket = ::Support::Ticket.new
    @ticket.messages.build
    @ticket.assign_user(current_user) if current_user
    @ticket.assign_to(@product.administrator)
    @ticket.target = @product
  end

  def create
    @ticket = ::Support::Ticket.new(ticket_params)
    @ticket.assign_user(current_user) if current_user
    @ticket.target = @product
    @ticket.assign_to(@product.administrator)
    @message = @ticket.messages.first
    @message.subject = subject
    if @ticket.valid?
      @ticket.save!
      WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Created, @message.id)
      if @product.action_free?
        flash[:success] = t('flash_messages.support.rfq_ticket.created')
      else
        flash[:success] = t('flash_messages.support.offer_ticket.created')
      end
      redirect_to support_ticket_path(@ticket)
      render_redirect_url_as_json if request.xhr?
    else
      render :new
    end
  end

  private

  def force_log_in
    redirect_to new_user_registration_path(return_to: product_path(@product)) unless current_user.present?
  end

  def find_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def subject
    if @product.action_free?
      sub = "Quote Request: #{@product.name}"
    else
      sub = "Offer: #{@product.name}"
    end
    sub
  end

  def ticket_params
    params.require(:support_ticket).permit(secured_params.support_ticket)
  end

end

