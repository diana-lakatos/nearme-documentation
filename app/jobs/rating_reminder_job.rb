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
    orders = Order.reviewable
    orders = orders.where("request_guest_rating_email_sent_at IS NULL OR request_host_and_product_rating_email_sent_at IS NULL")
    orders = orders.select do |order|
      @date >= order.ends_at && order.transactable && order.location.local_time.hour == 12
    end

    orders.each do |order|
      next if order.user.id == order.creator.id
      if order.request_guest_rating_email_sent_at.blank? && RatingSystem.active_with_subject(RatingConstants::GUEST).where(transactable_type_id: order.transactable_type_id).exists?
        WorkflowStepJob.perform("WorkflowStep::#{order.class.workflow_class}Workflow::EnquirerRatingRequested".constantize, order.id)
        order.update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if order.request_host_and_product_rating_email_sent_at.blank? && RatingSystem.active_with_subject([RatingConstants::HOST, RatingConstants::TRANSACTABLE]).where(transactable_type_id: order.transactable_type_id).exists?
        WorkflowStepJob.perform("WorkflowStep::#{order.class.workflow_class}Workflow::ListerRatingRequested".constantize, order.id)
        order.update_column(:request_host_and_product_rating_email_sent_at, Time.zone.now)
      end
    end
  end

end
