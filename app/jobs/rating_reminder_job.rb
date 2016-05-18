# Sends rating reminders at midday day after visit
class RatingReminderJob < Job

  def after_initialize(date_string)
    @date = Date.parse(date_string).yesterday
  end

  def perform
    # just to be sure we will get all rating systems
    PlatformContext.current = nil
    # check instances which have at least one active rating system
    RatingSystem.unscope(:order).active.uniq.pluck(:instance_id).each do |instance_id|
      Instance.find(instance_id).set_context!
      reservations_reminder
      orders_reminder
    end
    PlatformContext.current = nil
  end

  private

  def reservations_reminder
    reservations = Reservation.joins(:periods).confirmed.where('reservation_periods.date = ?', @date)
    reservations = reservations.where("request_guest_rating_email_sent_at IS NULL OR request_host_and_product_rating_email_sent_at IS NULL")
    reservations = reservations.select do |reservation|
      @date >= reservation.last_date && reservation.listing && reservation.location.local_time.hour == 12
    end

    reservations.each do |reservation|
      next if reservation.owner.id == reservation.creator.id
      if reservation.request_guest_rating_email_sent_at.blank? && RatingSystem.active_with_subject(RatingConstants::GUEST).where(transactable_type_id: reservation.transactable_type_id).exists?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestRatingRequested, reservation.id)
        reservation.update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if reservation.request_host_and_product_rating_email_sent_at.blank? && RatingSystem.active_with_subject([RatingConstants::HOST, RatingConstants::TRANSACTABLE]).where(transactable_type_id: reservation.transactable_type_id).exists?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::HostRatingRequested, reservation.id)
        reservation.update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

  def orders_reminder
    order_ids = Spree::Order.complete.where('completed_at = ?', @date).pluck(:id)
    line_items = Spree::LineItem.where(order_id: order_ids)
      .where("request_guest_rating_email_sent_at IS NULL OR request_host_and_product_rating_email_sent_at IS NULL")

    line_items.each do |line_item|

      if line_item.request_guest_rating_email_sent_at.blank? && RatingSystem.active_with_subject(RatingConstants::GUEST).where(transactable_type_id: line_item.transactable_type_id).exists?
        WorkflowStepJob.perform(WorkflowStep::LineItemWorkflow::GuestRatingRequested, line_item.id)
        line_item.update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if line_item.request_host_and_product_rating_email_sent_at.blank? && RatingSystem.active_with_subject([RatingConstants::HOST, RatingConstants::TRANSACTABLE]).where(transactable_type_id: line_item.transactable_type_id).exists?
        WorkflowStepJob.perform(WorkflowStep::LineItemWorkflow::HostAndProductRatingRequested, line_item.id)
        line_item.update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

end
