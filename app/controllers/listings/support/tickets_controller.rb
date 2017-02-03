# frozen_string_literal: true
class Listings::Support::TicketsController < ApplicationController
  before_action :find_listing
  before_action :force_log_in
  before_action :set_presenters

  def new
    @ticket = ::Support::Ticket.new
    @ticket.messages.build
    @ticket.assign_user(current_user) if current_user
    @ticket.assign_to(@listing.administrator)
    @ticket.target = @listing
  end

  def create
    details = params.delete(:details)
    @ticket = ::Support::Ticket.new(ticket_params)
    @ticket.assign_user(current_user) if current_user
    @ticket.target = @listing
    @ticket.assign_to(@listing.administrator)
    @ticket.reservation_details = details
    @message = @ticket.messages.first
    @message.subject = subject
    if @ticket.valid?
      @ticket.save!
      WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Created, @message.id)
      flash[:success] = if @listing.action_free_booking?
                          t('flash_messages.support.rfq_ticket.created')
                        else
                          t('flash_messages.support.offer_ticket.created')
                        end
      redirect_to support_ticket_path(@ticket)
      render_redirect_url_as_json if request.xhr?
    else
      params[:order] = details
      render :new
    end
  end

  private

  def force_log_in
    redirect_to new_api_user_path(return_to: @listing.try(:decorate).try(:show_path, quote_request: @listing.id)) unless current_user.present?
  end

  def find_listing
    @listing = Transactable.find(params[:listing_id])
  end

  def set_presenters
    @details = params[:order].presence || params[:details].presence || {}
    @pricing = @listing.action_type.pricings.find(@details[:transactable_pricing_id]).decorate if @details[:transactable_pricing_id]
    if @listing.event_booking?
      datetime = if !params[:details]
                   Time.at(@details[:dates].to_i).in_time_zone(@listing.timezone)
                 else
                   @details[:dates].try(:to_datetime)
      end
      @schedule_presenter = SchedulePresenter.new(datetime)
      @details[:dates] = datetime.to_s
      if datetime
        params[:order] ||= {}
        params[:order][:start_minute] = datetime.min.to_i + (60 * datetime.hour.to_i)
        params[:order][:end_minute] = params[:order][:start_minute]
      end
    else
      dates = @details[:dates].try(:split, ',') || []
      dates.map!(&:to_date)
      @date_presenter = DatePresenter.new(dates)
      if @details[:start_minute].present? && @details[:end_minute].present?
        @hourly_presenter = HourlyPresenter.new(dates.first, @details[:start_minute].to_i, @details[:end_minute].to_i)
      end
    end
  end

  def subject
    sub = if @listing.action_free_booking?
            "Quote Request: #{@listing.name} - "
          else
            "Offer: #{@listing.name} - "
          end
    sub += @ticket.reservation_details['quantity'].to_s # x #{@hourly_presenter.present? ? "#{@hourly_presenter.hours} #{I18n.t('hour', count: @hourly_presenter.hours.to_i)}" : @date_presenter.days_in_words}"
    sub
  end

  def ticket_params
    params.require(:support_ticket).permit(secured_params.support_ticket)
  end
end
