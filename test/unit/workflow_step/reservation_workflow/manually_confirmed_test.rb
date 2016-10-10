require 'test_helper'

class WorkflowStep::ReservationWorkflow::ManuallyConfirmedTest < ActiveSupport::TestCase
  context 'attachments' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
    end

    should 'return attachment if alert has it configured' do
      @manually_confirmed = WorkflowStep::ReservationWorkflow::ManuallyConfirmed.new(@reservation.id)
      assert_equal [{ name: 'my_name.ics', value: { mime_type: 'text/calendar', content: ReservationIcsBuilder.new(@reservation, @reservation.owner).to_s } }], @manually_confirmed.mail_attachments(stub(custom_options: { 'booking_calendar_attachment_name' => 'my_name.ics' }))
    end

    should 'return empty array of attachments if name not configured' do
      @manually_confirmed = WorkflowStep::ReservationWorkflow::ManuallyConfirmed.new(@reservation.id)
      assert_equal [], @manually_confirmed.mail_attachments(stub(custom_options: { 'booking_calendar_attachment_name' => '' }))
    end
  end
end
