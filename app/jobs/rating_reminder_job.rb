# Sends rating reminders at midday day after visit
class RatingReminderJob < Job

  def after_initialize(date_string)
    @date = Date.parse(date_string).yesterday
  end

  def perform
    # just to be sure we will get all rating systems
    PlatformContext.current = nil
    # check instances which have at least one active rating system
    RatingSystem.unscope(:order).active.pluck(:instance_id).uniq.each do |instance_id|
      Instance.find(instance_id).set_context!
      orders_reminder
    end
    PlatformContext.current = nil
  end

  private

  def orders_reminder
    reservations = Order.confirmed.where.not(archived_at: nil)
    reservations = reservations.where("request_guest_rating_email_sent_at IS NULL OR request_host_and_product_rating_email_sent_at IS NULL")
    reservations = reservations.select do |reservation|
      @date >= reservation.ends_at && reservation.transactable && reservation.location.local_time.hour == 12
    end

    reservations.each do |reservation|
      next if reservation.user.id == reservation.creator.id
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

end
