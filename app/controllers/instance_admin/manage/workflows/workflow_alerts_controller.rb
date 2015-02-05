class InstanceAdmin::Manage::Workflows::WorkflowAlertsController < InstanceAdmin::Manage::BaseController

  before_action :find_workflow_step
  before_action :find_custom_emails
  before_action :find_custom_email_layouts
  before_action :find_custom_smses

  def index
    @workflow_alerts = @workflow_step.workflow_alerts
  end

  def create
    @workflow_alert = @workflow_step.workflow_alerts.build(workflow_alert_params)
    if @workflow_alert.save
      flash[:success] = t 'flash_messages.instance_admin.manage.workflow_alerts.created'
      redirect_to instance_admin_manage_workflow_workflow_step_path(@workflow_step.workflow, @workflow_step)
    else
      flash[:error] = @workflow_alert.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @workflow_alert = @workflow_step.workflow_alerts.find(params[:id])
    if @workflow_alert.update_attributes(workflow_alert_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.workflow_alerts.updated'
      redirect_to instance_admin_manage_workflow_workflow_step_path(@workflow_step.workflow, @workflow_step)
    else
      flash[:error] = @workflow_alert.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @workflow_alert = @workflow_step.workflow_alerts.find(params[:id])
    @workflow_alert.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.workflow_alerts.updated'
    redirect_to instance_admin_manage_workflow_workflow_step_path(@workflow_step.workflow, @workflow_step)
  end

  private

  def find_workflow_step
    @workflow_step = WorkflowStep.find(params[:workflow_step_id])
  end

  def workflow_alert_params
    params.require(:workflow_alert).permit(secured_params.workflow_alert(@workflow_step.associated_class))
  end

  def find_custom_smses
    @custom_smses = (['company_sms_notifier/notify_host_of_no_payout_option', 'recurring_booking_sms_notifier/notify_guest_with_state_change', 'recurring_booking_sms_notifier/notify_host_with_confirmation', 'reservation_sms_notifier/notify_guest_with_state_change', 'reservation_sms_notifier/notify_host_with_confirmation', 'user_message_sms_notifier/notify_user_about_new_message'] + InstanceView.for_instance_id(PlatformContext.current.instance.id).custom_smses.pluck('path')).uniq
  end

  def find_custom_emails
    @custom_emails = (['post_action_mailer/sign_up_welcome', 'post_action_mailer/sign_up_verify',
                       'post_action_mailer/created_by_instance_admin', 'post_action_mailer/list',
                       'post_action_mailer/list_draft', 'post_action_mailer/unsubscription',
                       'post_action_mailer/user_created_invitation',
                       'inquiry_mailer/inquiring_user_notification',
                       'inquiry_mailer/listing_creator_notification', 'listing_mailer/share',
                       'rating_mailer/request_rating_of_guest_from_host',
                       'rating_mailer/request_rating_of_host_from_guest',
                       'reengagement_mailer/no_bookings', 'reengagement_mailer/one_booking',
                       'recurring_mailer/analytics', 'recurring_mailer/request_photos',
                       'recurring_mailer/share', 'reservation_mailer/notify_guest_of_cancellation_by_guest',
                       'reservation_mailer/notify_guest_of_cancellation_by_host',
                       'reservation_mailer/notify_guest_of_confirmation', 'reservation_mailer/notify_guest_of_expiration',
                       'reservation_mailer/notify_guest_of_rejection', 'reservation_mailer/notify_guest_with_confirmation',
                       'reservation_mailer/notify_host_of_cancellation_by_guest',
                       'reservation_mailer/notify_host_of_cancellation_by_host',
                       'reservation_mailer/notify_host_of_confirmation', 'reservation_mailer/notify_host_of_expiration',
                       'reservation_mailer/notify_host_of_rejection', 'reservation_mailer/notify_host_with_confirmation',
                       'reservation_mailer/notify_host_without_confirmation', 'reservation_mailer/pre_booking'] +
                       InstanceView.for_instance_id(PlatformContext.current.instance.id).custom_emails.pluck('path')).uniq
  end

  def find_custom_email_layouts
    @custom_email_layouts = (['layouts/mailer'] + InstanceView.for_instance_id(PlatformContext.current.instance.id).custom_email_layouts.pluck('path')).uniq
  end

  def permitting_controller_class
    'manage'
  end
end

