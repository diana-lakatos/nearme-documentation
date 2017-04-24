# frozen_string_literal: true
require 'test_helper'

class Utils::DefaultAlertsCreator::RecurringBookingCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @recurring_booking_creator = Utils::DefaultAlertsCreator::RecurringBookingCreator.new
  end

  should 'create all' do
    @recurring_booking_creator.expects(:notify_guest_of_expiration_email!).once
    @recurring_booking_creator.expects(:notify_host_of_expiration_email!).once
    @recurring_booking_creator.expects(:notify_guest_of_cancellation_by_guest_email!).once
    @recurring_booking_creator.expects(:notify_host_of_cancellation_by_guest_email!).once
    @recurring_booking_creator.expects(:notify_guest_of_cancellation_by_host_email!).once
    @recurring_booking_creator.expects(:notify_host_of_cancellation_by_host_email!).once
    @recurring_booking_creator.expects(:notify_guest_recurring_booking_created_and_confirmed_email!).once
    @recurring_booking_creator.expects(:notify_host_recurring_booking_created_and_confirmed_email!).once
    @recurring_booking_creator.expects(:notify_host_recurring_booking_created_and_pending_confirmation_email!).once
    @recurring_booking_creator.expects(:notify_host_recurring_booking_created_and_pending_confirmation_sms!).once
    @recurring_booking_creator.expects(:notify_guest_recurring_booking_created_and_pending_confirmation_email!).once
    @recurring_booking_creator.expects(:notify_guest_recurring_booking_confirmed_email!).once
    @recurring_booking_creator.expects(:notify_host_recurring_booking_confirmed_email!).once
    @recurring_booking_creator.expects(:notify_guest_recurring_booking_confirmed_sms!).once
    @recurring_booking_creator.expects(:notify_guest_recurring_booking_rejected_email!).once
    @recurring_booking_creator.expects(:notify_host_recurring_booking_rejected_email!).once

    @recurring_booking_creator.create_all!
  end

  context 'methods' do
    setup do
      @recurring_booking = FactoryGirl.create(:recurring_booking)
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
      @platform_context = PlatformContext.current
    end

    should '#notify_guest_of_cancellation_by_host' do
      @recurring_booking_creator.notify_guest_of_cancellation_by_host_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::RecurringBookingWorkflow::ListerCancelled, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @recurring_booking.owner.first_name, mail.html_part.body
      assert_contains @recurring_booking.transactable.name, mail.html_part.body
      assert_equal [@recurring_booking.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Your recurring booking for '#{@recurring_booking.transactable.name}' at #{@recurring_booking.location.street} was cancelled by the host", mail.subject
    end

    should '#notify_host_of_cancellation_by_host' do
      @recurring_booking_creator.notify_host_of_cancellation_by_host_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ListerCancelled, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @recurring_booking.transactable.administrator.first_name, mail.html_part.body
      assert_equal [@recurring_booking.transactable.administrator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] You just declined a recurring booking", mail.subject
    end

    should '#notify_guest_of_cancellation_by_guest' do
      @recurring_booking_creator.notify_guest_of_cancellation_by_guest_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::EnquirerCancelled, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @recurring_booking.owner.first_name, mail.html_part.body
      assert_equal [@recurring_booking.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] You just cancelled a recurring booking", mail.subject
    end

    should '#notify_host_of_cancellation_by_guest' do
      @recurring_booking_creator.notify_host_of_cancellation_by_guest_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::EnquirerCancelled, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @recurring_booking.transactable.creator.first_name, mail.html_part.body
      assert_equal [@recurring_booking.transactable.creator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@recurring_booking.owner.first_name} cancelled a recurring booking for '#{@recurring_booking.transactable.name}' at #{@recurring_booking.location.street}", mail.subject
    end

    should '#notify_guest_of_expiration' do
      @recurring_booking_creator.notify_guest_of_expiration_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::Expired, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @recurring_booking.owner.first_name, mail.html_part.body
      assert_contains @recurring_booking.transactable.name, mail.html_part.body

      assert_equal [@recurring_booking.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Your recurring booking for '#{@recurring_booking.transactable.name}' at #{@recurring_booking.location.street} has expired", mail.subject
    end

    should 'notify_guest_recurring_booking_created_and_confirmed_email!' do
      @recurring_booking_creator.notify_guest_recurring_booking_created_and_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithAutoConfirmation, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal [@recurring_booking.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@recurring_booking.owner.first_name}, your recurring booking has been confirmed", mail.subject
    end

    should 'notify host of confirmation email' do
      @recurring_booking_creator.notify_host_recurring_booking_created_and_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithAutoConfirmation, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @recurring_booking.transactable.creator.first_name, mail.html_part.body
      assert_equal [@recurring_booking.host.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@recurring_booking.owner.first_name} just booked your #{@platform_context.decorate.bookable_noun}!", mail.subject
    end

    should 'ask host for confirmation email' do
      @recurring_booking_creator.notify_host_recurring_booking_created_and_pending_confirmation_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @recurring_booking.transactable.creator.first_name, mail.html_part.body
      assert_equal [@recurring_booking.transactable.creator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@recurring_booking.owner.first_name} just booked your #{@platform_context.decorate.bookable_noun}!", mail.subject
    end

    should 'inform guest about recurring booking' do
      @recurring_booking_creator.notify_guest_recurring_booking_created_and_pending_confirmation_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @recurring_booking.transactable.name, mail.html_part.body
      assert_equal [@recurring_booking.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@recurring_booking.owner.first_name}, your recurring booking is pending confirmation", mail.subject
    end

    should 'inform guest of manual confirmation' do
      @recurring_booking_creator.notify_guest_recurring_booking_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal [@recurring_booking.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@recurring_booking.owner.first_name}, your recurring booking has been confirmed", mail.subject
    end

    should 'inform host of manual confirmation' do
      @recurring_booking_creator.notify_host_recurring_booking_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @recurring_booking.transactable.creator.first_name, mail.html_part.body
      assert_equal [@recurring_booking.transactable.creator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Thanks for confirming!", mail.subject
    end

    context 'guest rejection' do
      setup do
        @recurring_booking_creator.notify_guest_recurring_booking_rejected_email!
      end

      should 'include reason when it is present' do
        @recurring_booking.update_attribute(:rejection_reason, 'You stinks.')
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::RecurringBookingWorkflow::Rejected, @recurring_booking.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains @recurring_booking.transactable.name, mail.html_part.body
        assert_contains 'They said:', mail.html_part.body
        assert_contains @recurring_booking.rejection_reason, mail.html_part.body

        assert_equal [@recurring_booking.owner.email], mail.to
        assert_equal "[#{@platform_context.decorate.name}] Can we help, #{@recurring_booking.owner.first_name}?", mail.subject
      end

      should 'not include reason when it is not present' do
        @recurring_booking.update_attribute(:rejection_reason, nil)
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::RecurringBookingWorkflow::Rejected, @recurring_booking.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains @recurring_booking.transactable.name, mail.html_part.body
        assert_does_not_contain 'They said:', mail.html_part.body
        assert_does_not_contain @recurring_booking.rejection_reason, mail.html_part.body

        assert_equal [@recurring_booking.owner.email], mail.to
        assert_equal "[#{@platform_context.decorate.name}] Can we help, #{@recurring_booking.owner.first_name}?", mail.subject
      end

      should 'include nearme transactables when it is present' do
        @transactable = FactoryGirl.create(:transactable)
        User.any_instance.stubs(:listings_in_near).returns([@transactable])

        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::RecurringBookingWorkflow::Rejected, @recurring_booking.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains @transactable.name, mail.html_part.body
      end

      should 'not include nearme transactables when it is not present' do
        @recurring_booking.owner.stubs(listings_in_near: [])
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::RecurringBookingWorkflow::Rejected, @recurring_booking.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_does_not_contain 'But we have you covered!', mail.html_part.body
      end
    end

    should 'notify host of rejection' do
      @recurring_booking_creator.notify_host_recurring_booking_rejected_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::RecurringBookingWorkflow::Rejected, @recurring_booking.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @recurring_booking.transactable.name, mail.html_part.body

      assert_equal [@recurring_booking.transactable.administrator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Can we help, #{@recurring_booking.transactable.administrator.first_name}?", mail.subject
    end

    context 'sms' do
      setup do
        Googl.stubs(:shorten).returns(stub(short_url: 'http://goo.gl/abf324'))
        @recurring_booking.owner.update_attributes(mobile_number: '987654421', sms_notifications_enabled: true)
        @recurring_booking.creator.update_attributes(mobile_number: '124456789', sms_notifications_enabled: true)
      end

      context '#notify_host_with_confirmation sms' do
        setup do
          @recurring_booking_creator.notify_host_recurring_booking_created_and_pending_confirmation_sms!
        end
        should 'render with the reservation' do
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation.new(@recurring_booking.id))
          assert_equal '+1124456789', sms.to
          assert sms.body =~ Regexp.new("You have received a recurring booking request on #{@recurring_booking.instance.name}")
          assert sms.body =~ /Please confirm or decline from your dashboard:/
          assert sms.body =~ /http:\/\/goo.gl/
        end

        should 'not render if host had disabled sms notifications' do
          @recurring_booking.creator.update_attribute(:sms_notifications_enabled, false)
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation.new(@recurring_booking.id))
          assert sms.is_a?(SmsNotifier::NullMessage), "#{sms.class} is not SmsNotifer::NullMessage"
          refute sms.deliver
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, @recurring_booking.id)
        end
      end

      context '#notify_guest_of_manual_confirmation_sms' do
        setup do
          @recurring_booking_creator.notify_guest_recurring_booking_confirmed_sms!
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, @recurring_booking.id)
        end

        should 'render with the reservation' do
          @recurring_booking.update_column(:state, 'confirmed')
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed.new(@recurring_booking.id))
          assert_equal '+1987654421', sms.to
          assert sms.body =~ Regexp.new("Your recurring booking for #{@recurring_booking.transactable.name} was Confirmed. View booking:"), "wrong body: #{sms.body}"
          assert sms.body =~ /http:\/\/goo.gl/, "Sms body does not include http://goo.gl: #{sms.body}"
        end
      end
    end
  end
end
