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
    mail(options)
  end

  def mail_type
     DNM::MAIL_TYPES::TRANSACTIONAL
  end

  protected

  def to
    case @workflow_alert.recipient_type
    when 'lister'
      @step.lister.email
    when 'enquirer'
      @step.enquirer.email
    when 'administrator'
      InstanceAdmin.joins(:user).pluck(:email)
    end
  end

  def options
    {
      template_name: @workflow_alert.template_path,
      to: to,
      from: @workflow_alert.from.try(:split, ','),
      cc: @workflow_alert.cc.try(:split, ','),
      bcc: @workflow_alert.bcc.try(:split, ','),
      reply_to: @workflow_alert.reply_to.try(:split, ','),
      subject: Liquid::Template.parse(@workflow_alert.subject).render(@step.data.merge('platform_context' => PlatformContext.current.decorate).stringify_keys),
      layout_path: @workflow_alert.layout_path
    }
  end
end
