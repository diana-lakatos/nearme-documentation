class WorkflowStep::PurchaseWorkflow::ManuallyConfirmed < WorkflowStep::PurchaseWorkflow::BaseStep
  CUSTOM_OPTIONS  = [:booking_calendar_attachment_name]

  def mail_attachments(alert)
    if alert.custom_options['booking_calendar_attachment_name'].present?
      [{ name: alert.custom_options['booking_calendar_attachment_name'], value: { mime_type: 'text/calendar', content: ReservationIcsBuilder.new(@reservation, @reservation.owner).to_s } }]
    else
      super
    end
  end
end
