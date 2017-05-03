# frozen_string_literal: true
class Utils::DefaultAlertsCreator::SignUpCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_email_verification_email!
    create_welcome_email!
    create_guest_welcome_email!
    create_guest_verify_email!
    create_host_welcome_email!
    create_host_verify_email!
    create_create_user_by_admin_email!
    create_notify_of_wrong_phone_number_email!
    create_create_user_via_bulk_uploader_email!
    create_approved_email!
  end

  def create_email_verification_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::AccountCreated,
                  name: 'Email verification email',
                  path: 'post_action_mailer/sign_up_verify',
                  subject: '{{user.first_name}}, please verify your {{platform_context.name}} email',
                  alert_type: 'email',
                  recipient_type: 'enquirer')
  end

  def create_welcome_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::AccountCreated,
                  name: 'Welcome email',
                  path: 'post_action_mailer/sign_up_welcome',
                  subject: '{{user.first_name}}, welcome to {{platform_context.name}}!',
                  alert_type: 'email',
                  recipient_type: 'enquirer',
                  delay: 30)
  end

  def create_guest_welcome_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::EnquirerAccountCreated,
                  name: 'Welcome email',
                  path: 'post_action_mailer/guest_sign_up_welcome',
                  subject: '{{user.first_name}}, welcome to {{platform_context.name}}!',
                  alert_type: 'email',
                  recipient_type: 'enquirer',
                  delay: 30)
  end

  def create_guest_verify_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::EnquirerAccountCreated,
                  name: 'Email verification email',
                  path: 'post_action_mailer/sign_up_verify',
                  subject: '{{user.first_name}}, please verify your {{platform_context.name}} email',
                  alert_type: 'email',
                  recipient_type: 'enquirer')
  end

  def create_host_welcome_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::ListerAccountCreated,
                  name: 'Welcome email',
                  path: 'post_action_mailer/host_sign_up_welcome',
                  subject: '{{user.first_name}}, welcome to {{platform_context.name}}!',
                  alert_type: 'email',
                  recipient_type: 'enquirer',
                  delay: 30)
  end

  def create_host_verify_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::ListerAccountCreated,
                  name: 'Email verification email',
                  path: 'post_action_mailer/sign_up_verify',
                  subject: '{{user.first_name}}, please verify your {{platform_context.name}} email',
                  alert_type: 'email',
                  recipient_type: 'enquirer')
  end

  def create_create_user_by_admin_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::CreatedByAdmin,
                  name: 'user_created_by_admin_email',
                  path: 'post_action_mailer/created_by_instance_admin',
                  subject: '{{new_user.first_name}}, you were invited to {{platform_context.name}} by {{creator.name}}!',
                  alert_type: 'email',
                  recipient_type: 'enquirer')
  end

  def create_notify_of_wrong_phone_number_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::WrongPhoneNumber,
                  name: 'notify user of wrong phone number email',
                  path: 'user_mailer/notify_about_wrong_phone_number',
                  subject: "{{user.first_name}}, we can't reach you!",
                  alert_type: 'email',
                  recipient_type: 'enquirer')
  end

  def create_create_user_via_bulk_uploader_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::CreatedViaBulkUploader,
                  name: 'user created via bulk uploader email',
                  path: 'post_action_mailer/user_created_invitation',
                  subject: '{{user.first_name}}, you were invited to {{platform_context.name}}!',
                  alert_type: 'email',
                  recipient_type: 'enquirer')
  end

  def create_approved_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::Approved,
                  name: 'user_approved_email',
                  path: 'vendor_approval_mailer/notify_host_of_user_approval',
                  subject: '{{ user.first_name }}, you have been approved at {{ platform_context.name }}!',
                  alert_type: 'email',
                  recipient_type: 'enquirer',
                  delay: 0)
  end

  def create_lister_onboarding_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::ListerOnboarded,
                  name: 'lister_onboarded',
                  path: 'post_action_mailer/lister_onboarded',
                  subject: '{{ user.first_name }}, you have completed profile!',
                  alert_type: 'email',
                  recipient_type: 'lister',
                  delay: 0)
  end

  def create_enquirer_onboarding_email!
    create_alert!(associated_class: WorkflowStep::SignUpWorkflow::EnquirerOnboarded,
                  name: 'enquirer_onboarded',
                  path: 'post_action_mailer/enquirer_onboarded',
                  subject: '{{ user.first_name }}, you have completed profile!',
                  alert_type: 'email',
                  recipient_type: 'lister',
                  delay: 0)
  end

  protected

  def workflow_type
    'sign_up'
  end
end
