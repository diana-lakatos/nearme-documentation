# Sends rating reminders at midday day after visit
class RatingReminderJob < Job

  def after_initialize(date_string)
    @date = Date.parse(date_string).yesterday
  end

  def perform
    reservations_reminder
    orders_reminder
  end

  private

  def reservations_reminder
    clear_platform_context
    reservations = Reservation.joins(:periods).confirmed.where('reservation_periods.date = ?', @date)
    reservations = reservations.where("request_guest_rating_email_sent_at IS NULL OR request_host_and_product_rating_email_sent_at IS NULL")
    reservations = reservations.select do |reservation|
      reservation.last_date >= @date && reservation.listing && reservation.location.local_time.hour == 12
    end

    reservations.each do |reservation|
      PlatformContext.current = PlatformContext.new(reservation.platform_context_detail)

      if reservation.request_guest_rating_email_sent_at.blank?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestRatingRequested, reservation.id)
        reservation.update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if reservation.request_host_and_product_rating_email_sent_at.blank?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::HostRatingRequested, reservation.id)
        reservation.update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

  def orders_reminder
    clear_platform_context
    order_ids = Spree::Order.complete.where('completed_at = ?', @date).pluck(:id)
    line_items = Spree::LineItem.where(order_id: order_ids)
      .where("request_guest_rating_email_sent_at IS NULL OR request_host_and_product_rating_email_sent_at IS NULL")

    line_items.each do |line_item|
      PlatformContext.current = PlatformContext.new(line_item.platform_context_detail)

      if line_item.request_guest_rating_email_sent_at.blank?
        WorkflowStepJob.perform(WorkflowStep::LineItemWorkflow::GuestRatingRequested, line_item.id)
        line_item.update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if line_item.request_host_and_product_rating_email_sent_at.blank?
        WorkflowStepJob.perform(WorkflowStep::LineItemWorkflow::HostAndProductRatingRequested, line_item.id)
        line_item.update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

  def clear_platform_context
    PlatformContext.clear_current
  end
end