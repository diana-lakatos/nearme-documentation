class DataImporter::Inviter

  def send_invitation_emails(new_users_emails)
    new_users_emails.each do |email, password|
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::CreatedViaBulkUploader, User.find_by_email(email).id, password)
    end
  end

end

