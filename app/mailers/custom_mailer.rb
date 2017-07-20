class CustomMailer < InstanceMailer
  def custom_mail(step, workflow_id, metadata: {})
    metadata.deep_stringify_keys!
    @step = step
    return unless @step.should_be_processed?
    @workflow_alert = WorkflowAlert.find(workflow_id)
    return unless @workflow_alert.should_be_triggered?(step, metadata: metadata)
    @step.data.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
    instance_variable_set(:"@metadata", metadata)
    @step.mail_attachments(@workflow_alert).each do |attachment|
      attachments[attachment[:name].to_s] = attachment[:value]
    end
    # it's valid email if at least one of these field is present
    if options[:to].blank? && options[:cc].blank? && options[:bcc].blank?
      MarketplaceLogger.error(
        MarketplaceErrorLogger::BaseLogger::MAILER_ERROR,
        "Sending e-mail \"#{@workflow_alert}(id=#{@workflow_alert.id}\" failed because of 'to' was empty"
      )
    else
      WorkflowAlertLogger.new(@workflow_alert).log!
      if (locale = recipient_locale).present?
        I18n.locale = locale
      end
      mail(options)
    end
  end

  protected

  def get_email_for_type_with_fallback(field)
    begin
      case @workflow_alert.send("#{field}_type")
      when 'lister'
        [@step.lister.try(:email)]
      when 'enquirer'
        [@step.enquirer.try(:email)]
      else
        InstanceAdminRole.where(name: @workflow_alert.send("#{field}_type")).first.try(:instance_admins).try(:joins, :user).try(:pluck, :email) || []
      end + (@workflow_alert.send(field).try(:split, ',') || [])
    end.compact.uniq
  end

  def filter_emails_to_only_these_which_accepts_emails(emails)
    emails.map do |email|
      u = User.with_deleted.where(email: email, instance_id: PlatformContext.current.instance.id).first
      if u.nil? || (!u.deleted? && u.accept_emails?)
        email
      else
        nil
      end
    end.compact
  end

  def recipient_locale
    case @workflow_alert.recipient_type
    when 'lister'
      @step.lister
    when 'enquirer'
      @step.enquirer
    else
      InstanceAdminRole.where(name: @workflow_alert.recipient_type).try(:first).try(:instance_admins).try(:first).try(:user)
    end.try(:language)
  end

  def get_bcc_emails
    emails = @workflow_alert.bcc.try(:split, ',') || []

    case @workflow_alert.bcc_type
      when 'collaborators'
        emails += @step.collaborators.try(:map, &:email)
      when 'members'
        emails += @step.members.try(:map, &:email)
    end

    emails
  end

  def options
    @options ||= {
      template_name: @workflow_alert.template_path,
      to: filter_emails_to_only_these_which_accepts_emails(get_email_for_type_with_fallback('recipient')).reject(&:blank?),
      from: get_email_for_type_with_fallback('from'),
      reply_to: get_email_for_type_with_fallback('reply_to'),
      cc: filter_emails_to_only_these_which_accepts_emails(@workflow_alert.cc.try(:split, ',') || []),
      bcc: filter_emails_to_only_these_which_accepts_emails(get_bcc_emails),
      subject: Liquid::Template.parse(@workflow_alert.subject).render(@step.data.merge('platform_context' => PlatformContext.current.decorate).stringify_keys, filters: [Liquid::LiquidFilters]),
      layout_path: @workflow_alert.layout_path,
      transactable_type_id: @step.transactable_type_id
    }
  end
end
