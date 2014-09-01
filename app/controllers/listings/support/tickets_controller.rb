class Listings::Support::TicketsController < ApplicationController
  before_filter :find_listing
  before_filter :force_log_in
  before_filter :set_presenters

  def new
    @ticket = ::Support::Ticket.new
    @ticket.messages.build
    @ticket.assign_user(current_user) if current_user
    @ticket.assign_to(@listing.administrator)
    @ticket.target = @listing
  end

  def create
    @ticket = ::Support::Ticket.new(ticket_params)
    @ticket.assign_user(current_user) if current_user
    @ticket.target = @listing
    @ticket.assign_to(@listing.administrator)
    @message = @ticket.messages.first
    @message.subject = subject
    @message.message = message(@message.message)
    if @ticket.valid?
      @ticket.save!
      SupportMailer.enqueue.rfq_request_received(@ticket, @message)
      SupportMailer.enqueue.rfq_support_received(@ticket, @message)
      flash[:success] = t('flash_messages.support.ticket.created')
      redirect_to support_ticket_path(@ticket)
    else
      render :new
    end
  end

  private

  def force_log_in
    redirect_to new_user_registration_path(return_to: location_url(@listing.location, @listing, quote_request: @listing.id)) unless current_user.present?
  end

  def find_listing
    @listing = Transactable.find(params[:listing_id])
  end

  def set_presenters
    @details = params[:reservation_request].presence || params[:details].presence || {}
    dates = @details[:dates].try(:split, ',') || []
    dates.map!(&:to_date)
    @date_presenter = DatePresenter.new(dates)
    if @details[:start_minute].present? && @details[:end_minute].present?
      @hourly_presenter = HourlyPresenter.new(dates.first, @details[:start_minute].to_i, @details[:end_minute].to_i)
    end
  end

  def subject
    sub = "RFQ - #{@listing.id} - #{@details[:quantity]} x "
    if @hourly_presenter.present?
      sub += @hourly_presenter.hourly_summary_no_html(true)
    else
      sub += @date_presenter.days_in_words
    end
    sub
  end

  def message(original_message)
    if !@hourly_presenter.present?
      original_message +=  "\r\n\r\n" + @date_presenter.selected_dates_summary_no_html
    end
    original_message
  end

  def ticket_params
    params.require(:support_ticket).permit(secured_params.support_ticket)
  end

end

