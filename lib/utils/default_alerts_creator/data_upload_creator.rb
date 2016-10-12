class Utils::DefaultAlertsCreator::DataUploadCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_uploader_of_failed_import_email!
    notify_uploader_of_finished_import_email!
  end

  def notify_uploader_of_failed_import_email!
    create_alert!(associated_class: WorkflowStep::DataUploadWorkflow::Failed, name: 'notify_uploader_of_failed_import_email', path: 'data_upload_mailer/notify_uploader_of_failed_import', subject: "[{{platform_context.name}}] Importing '{{data_upload.csv_file_identifier}}' has failed", alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_uploader_of_finished_import_email!
    create_alert!(associated_class: WorkflowStep::DataUploadWorkflow::Finished, name: 'notify_uploader_of_finished_import_email', path: 'data_upload_mailer/notify_uploader_of_finished_import', subject: "[{{platform_context.name}}] Importing '{{data_upload.csv_file_identifier}}' has finished", alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'data_upload'
  end
end
