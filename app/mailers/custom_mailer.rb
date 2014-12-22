class CustomMailer < InstanceMailer

  def custom_mail(step, workflow_id)
    @step = step
    return unless @step.should_be_processed?
    @workflow_alert = WorkflowAlert.find(workflow_id)
    @step.data.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
    @step.mail_attachments(@workflow_alert).each do |attachment|
      attachments[attachment[:name].to_s] = attachment[:value]
    end
    WorkflowAlertLogger.new(@workflow_alert).log!
    mail(options)
  end

  def mail_type
     DNM::MAIL_TYPES::TRANSACTIONAL
  end

  protected

  def get_email_for_type_with_fallback(field)
    case @workflow_alert.send("#{field}_type")
    when 'lister'
      @step.lister.email
    when 'enquirer'
      @step.enquirer.email
    when 'administrator'
      InstanceAdmin.joins(:user).pluck(:email)
    else
      @workflow_alert.send(field).try(:split, ',')
    end
  end

  def to
  end

  def options
    {
      template_name: @workflow_alert.template_path,
      to: get_email_for_type_with_fallback('recipient'),
      from: get_email_for_type_with_fallback('from'),
      reply_to: get_email_for_type_with_fallback('reply_to'),
      cc: @workflow_alert.cc.try(:split, ','),
      bcc: @workflow_alert.bcc.try(:split, ','),
      subject: Liquid::Template.parse(@workflow_alert.subject).render(@step.data.merge('platform_context' => PlatformContext.current.decorate).stringify_keys),
      layout_path: @workflow_alert.layout_path
    }
  end
end
