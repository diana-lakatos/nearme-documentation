# frozen_string_literal: true
require 'test_helper'

class Utils::DefaultAlertsCreator::ReservationCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @reservation_creator = Utils::DefaultAlertsCreator::ReservationCreator.new
  end
  should 'create all' do
    @reservation_creator.expects(:notify_guest_of_expiration_email!).once
    @reservation_creator.expects(:notify_host_of_expiration_email!).once
    @reservation_creator.expects(:notify_guest_of_cancellation_by_guest_email!).once
    @reservation_creator.expects(:notify_host_of_cancellation_by_guest_email!).once
    @reservation_creator.expects(:notify_guest_of_cancellation_by_host_email!).once
    @reservation_creator.expects(:notify_host_of_cancellation_by_host_email!).once
    @reservation_creator.expects(:notify_guest_reservation_created_and_confirmed_email!).once
    @reservation_creator.expects(:notify_host_reservation_created_and_confirmed_email!).once
    @reservation_creator.expects(:notify_host_reservation_created_and_pending_confirmation_email!).once
    @reservation_creator.expects(:notify_host_reservation_created_and_pending_confirmation_sms!).once
    @reservation_creator.expects(:notify_guest_reservation_created_and_pending_confirmation_email!).once
    @reservation_creator.expects(:notify_guest_reservation_confirmed_email!).once
    @reservation_creator.expects(:notify_host_reservation_confirmed_email!).once
    @reservation_creator.expects(:notify_guest_reservation_confirmed_sms!).once
    @reservation_creator.expects(:notify_guest_reservation_host_cancel_sms!).once
    @reservation_creator.expects(:notify_guest_reservation_rejected_email!).once
    @reservation_creator.expects(:notify_guest_of_payment_request_email!).once
    @reservation_creator.expects(:notify_host_reservation_rejected_email!).once
    @reservation_creator.expects(:notify_guest_pre_booking_email!).once
    @reservation_creator.expects(:request_rating_of_guest_from_host_email!).once
    @reservation_creator.expects(:request_rating_of_host_from_guest_email!).once
    @reservation_creator.expects(:notify_host_of_approved_payment!).once
    @reservation_creator.expects(:notify_host_of_declined_payment!).once
    @reservation_creator.expects(:notify_guest_of_submitted_checkout!).once
    @reservation_creator.expects(:notify_guest_of_submitted_checkout_with_failed_authorization!).once
    @reservation_creator.create_all!
  end

  context 'methods' do
    setup do
      @user = FactoryGirl.create(:user_with_sms_notifications_enabled)
      @reservation = FactoryGirl.create(:unconfirmed_reservation, user: @user)
      @reservation.periods = [ReservationPeriod.new(date: Date.parse('2012/12/12')), ReservationPeriod.new(date: Date.parse('2012/12/13'))]
      @reservation.save!
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
      @platform_context = PlatformContext.current
      @expected_dates = 'December 12, 2012 – December 13, 2012'
    end

    should '#notify_guest_of_cancellation_by_host' do
      @reservation_creator.notify_guest_of_cancellation_by_host_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::ListerCancelled, @reservation.id, as: @reservation.creator)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.owner.first_name, mail.html_part.body
      assert_contains @reservation.transactable.name, mail.html_part.body
      assert_contains @reservation.transactable.transactable_type.bookable_noun.pluralize, mail.html_part.body
      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Your booking for '#{@reservation.transactable.name}' at #{@reservation.location.street} was cancelled by the host", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should '#notify_host_of_cancellation_by_host' do
      @reservation_creator.notify_host_of_cancellation_by_host_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerCancelled, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.administrator.first_name, mail.html_part.body
      assert_equal [@reservation.transactable.administrator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] You just declined a booking", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should '#notify_guest_of_cancellation_by_guest' do
      @reservation_creator.notify_guest_of_cancellation_by_guest_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerCancelled, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.owner.first_name, mail.html_part.body
      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] You just cancelled a booking", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should '#notify_host_of_cancellation_by_guest' do
      @reservation_creator.notify_host_of_cancellation_by_guest_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerCancelled, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @reservation.transactable.creator.first_name, mail.html_part.body
      assert_equal [@reservation.transactable.creator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name} cancelled a booking for '#{@reservation.transactable.name}' at #{@reservation.location.street}", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should '#notify_guest_of_expiration' do
      @reservation_creator.notify_guest_of_expiration_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::Expired, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @reservation.owner.first_name, mail.html_part.body
      assert_contains @reservation.transactable.name, mail.html_part.body

      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Your booking for '#{@reservation.transactable.name}' at #{@reservation.location.street} has expired", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'notify_guest_reservation_created_and_confirmed_email!' do
      @reservation_creator.notify_guest_reservation_created_and_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.creator.first_name, mail.html_part.body
      assert_contains @expected_dates, mail.html_part.body
      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name}, your booking has been confirmed", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'notify host of confirmation email' do
      @reservation_creator.notify_host_reservation_created_and_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.creator.first_name, mail.html_part.body
      assert_contains @expected_dates, mail.html_part.body
      assert_equal [@reservation.host.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name} just booked your #{@platform_context.decorate.bookable_noun}!", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'ask host for confirmation email' do
      @reservation_creator.notify_host_reservation_created_and_pending_confirmation_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.creator.first_name, mail.html_part.body
      assert_equal [@reservation.transactable.creator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name} just booked your #{@platform_context.decorate.bookable_noun}!", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'inform guest about booking' do
      @reservation_creator.notify_guest_reservation_created_and_pending_confirmation_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @reservation.transactable.name, mail.html_part.body
      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name}, your booking is pending confirmation", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'inform guest of manual confirmation' do
      @reservation_creator.notify_guest_reservation_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ManuallyConfirmed, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.creator.first_name, mail.html_part.body
      assert_contains @expected_dates, mail.html_part.body
      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name}, your booking has been confirmed", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'inform host of manual confirmation' do
      @reservation_creator.notify_host_reservation_confirmed_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ManuallyConfirmed, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains @reservation.transactable.creator.first_name, mail.html_part.body
      assert_equal [@reservation.transactable.creator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Thanks for confirming!", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    context 'guest rejection' do
      setup do
        @reservation_creator.notify_guest_reservation_rejected_email!
      end

      should 'include reason when it is present' do
        @reservation.update_attribute(:rejection_reason, 'You stinks.')
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains @reservation.transactable.name, mail.html_part.body
        assert_contains 'They said:', mail.html_part.body
        assert_contains @reservation.rejection_reason, mail.html_part.body

        assert_equal [@reservation.owner.email], mail.to
        assert_equal "[#{@platform_context.decorate.name}] Can we help, #{@reservation.owner.first_name}?", mail.subject
        assert_not_contains 'Liquid error:', mail.html_part.body
      end

      should 'not include reason when it is not present' do
        @reservation.update_attribute(:rejection_reason, nil)
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains @reservation.transactable.name, mail.html_part.body
        assert_does_not_contain 'They said:', mail.html_part.body
        assert_does_not_contain @reservation.rejection_reason, mail.html_part.body

        assert_equal [@reservation.owner.email], mail.to
        assert_equal "[#{@platform_context.decorate.name}] Can we help, #{@reservation.owner.first_name}?", mail.subject
        assert_not_contains 'translation missing:', mail.html_part.body
      end

      should 'include nearme listings when it is present' do
        @listing = FactoryGirl.create(:transactable)
        @listing2 = FactoryGirl.create(:transactable, :fixed_price)
        User.any_instance.stubs(:listings_in_near).returns([@listing, @listing2])

        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains @listing.name, mail.html_part.body
        assert_not_contains 'Liquid error:', mail.html_part.body
        assert_not_contains 'translation missing:', mail.html_part.body
      end

      should 'not include nearme listings when it is not present' do
        @reservation.owner.stubs(listings_in_near: [])
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_does_not_contain 'But we have you covered!', mail.html_part.body
      end
    end

    should 'notify host of rejection' do
      @reservation_creator.notify_host_reservation_rejected_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.name, mail.html_part.body

      assert_equal [@reservation.transactable.administrator.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Can we help, #{@reservation.transactable.creator.first_name}?", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'request payment' do
      @reservation_creator.notify_guest_of_payment_request_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::PaymentRequest, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.name, mail.html_part.body

      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] Your booking for '#{@reservation.transactable.name}' at #{@reservation.location.street} requires payment", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'pre booking' do
      @reservation_creator.notify_guest_pre_booking_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::OneDayToBooking, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains @reservation.transactable.name, mail.html_part.body

      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] #{@reservation.owner.first_name}, your booking is tomorrow!", mail.subject
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'notify host of approved payment' do
      @reservation_creator.notify_host_of_approved_payment!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::EnquirerApprovedPayment, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert mail.html_part.body.include?(@user.first_name)

      assert_equal [@reservation.transactable.creator.email], mail.to
      assert_equal "[DesksNearMe] #{@reservation.owner.first_name} confirmed payment!", mail.subject
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    should 'notify host of declined payment' do
      @reservation.update_attribute(:rejection_reason, 'You stinks.')
      @reservation_creator.notify_host_of_declined_payment!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::EnquirerDeclinedPayment, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert mail.html_part.body.include?(@user.first_name)
      assert_equal [@reservation.transactable.creator.email], mail.to
      assert_equal "[DesksNearMe] #{@reservation.owner.first_name} declined payment!", mail.subject
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
      assert_contains 'dashboard/company/host_reservations?state=unconfirmed', mail.html_part.body
    end

    should 'request_rating_of_guest_from_host_email' do
      @reservation_creator.request_rating_of_guest_from_host_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::EnquirerRatingRequested, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains "How was #{@reservation.owner.first_name}, your recent #{@platform_context.decorate.lessee}?", mail.html_part.body

      assert_equal [@reservation.host.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] How was your experience hosting #{@reservation.owner.first_name}?", mail.subject
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    context 'skip payment authorization' do
      setup do
        TransactableType.update_all(skip_payment_authorization: true, hours_for_guest_to_confirm_payment: 24)
        @reservation = FactoryGirl.create(:reservation_with_invoice, user: @user)
        @reservation.periods.update_all(description: 'my period')
      end

      should 'notify_guest_of_submitted_checkout' do
        @reservation_creator.notify_guest_of_submitted_checkout!
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::ListerSubmittedCheckout, @reservation.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains 'Please review it and approve or decline in your dashboard', mail.html_part.body
        assert_equal [@reservation.owner.email], mail.to
        assert_equal "[#{@platform_context.decorate.name}] #{@reservation.transactable.name} submitted invoice", mail.subject
        assert_contains 'href="http://custom.domain.com/', mail.html_part.body
        assert_not_contains 'href="https://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body
        assert_not_contains 'Liquid error:', mail.html_part.body
        assert_not_contains 'translation missing:', mail.html_part.body
        assert_contains 'Something cool', mail.html_part.body
        assert_contains 'my period', mail.html_part.body
      end

      should 'notify_guest_of_submitted_checkout_with_failed_authorization' do
        @reservation_creator.notify_guest_of_submitted_checkout_with_failed_authorization!
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::ListerSubmittedCheckoutButAuthorizationFailed, @reservation.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_contains 'Unfortunately we had an issue with authorizing your credit card. Please update your payment information to be able to pay.', mail.html_part.body
        assert_equal [@reservation.owner.email], mail.to
        assert_equal "[#{@platform_context.decorate.name}] #{@reservation.transactable.name} submitted invoice", mail.subject
        assert_contains 'href="https://custom.domain.com/', mail.html_part.body
        assert_not_contains 'href="https://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body
        assert_not_contains 'Liquid error:', mail.html_part.body
        assert_not_contains 'translation missing:', mail.html_part.body
        assert_contains 'my period', mail.html_part.body
        assert_contains 'Something cool', mail.html_part.body
      end
    end

    should 'request_rating_of_host_from_guest_email!' do
      @reservation_creator.request_rating_of_host_from_guest_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(::WorkflowStep::ReservationWorkflow::ListerRatingRequested, @reservation.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_contains "How was it, #{@reservation.owner.first_name}?", mail.html_part.body
      assert_contains @reservation.transactable.name, mail.html_part.body

      assert_equal [@reservation.owner.email], mail.to
      assert_equal "[#{@platform_context.decorate.name}] How was your experience at '#{@reservation.transactable.name}'?", mail.subject
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
    end

    context 'sms' do
      setup do
        Googl.stubs(:shorten).returns(stub(short_url: 'http://goo.gl/abf324'))
        @reservation.owner.update_attributes(mobile_number: '987654421', sms_notifications_enabled: true)
        @reservation.creator.update_attributes(mobile_number: '124456789', sms_notifications_enabled: true)
      end

      context '#notify_host_with_confirmation sms' do
        setup do
          @reservation_creator.notify_host_reservation_created_and_pending_confirmation_sms!
        end
        should 'render with the reservation' do
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation.new(@reservation.id))
          assert_equal '+1124456789', sms.to
          assert sms.body =~ Regexp.new("You have received a booking request on #{@reservation.instance.name}")
          assert sms.body =~ /Please confirm or decline from your dashboard:/
          assert sms.body =~ /http:\/\/goo.gl/
        end

        should 'not render if host had disabled sms notifications' do
          @reservation.creator.update_attribute(:sms_notifications_enabled, false)
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation.new(@reservation.id))
          assert sms.is_a?(SmsNotifier::NullMessage)
          refute sms.deliver
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, @reservation.id)
        end
      end

      context '#notify_guest_of_manual_confirmation_sms' do
        setup do
          @reservation_creator.notify_guest_reservation_confirmed_sms!
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ManuallyConfirmed, @reservation.id)
        end

        should 'render with the reservation' do
          @reservation.confirm!
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::ReservationWorkflow::ManuallyConfirmed.new(@reservation.id))
          assert_equal '+1987654421', sms.to
          assert sms.body =~ Regexp.new("Your booking for #{@reservation.transactable.name} was confirmed. View booking:"), "wrong body: #{sms.body}"
          assert sms.body =~ /http:\/\/goo.gl/, "Sms body does not include http://goo.gl: #{sms.body}"
          assert_not_contains 'Liquid error:', sms.body
          assert_not_contains 'translation missing:', sms.body
        end
      end

      context '#notify_guest_of_reject_sms' do
        setup do
          @reservation_creator.notify_guest_reservation_reject_sms!
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
        end

        should 'render with the reservation' do
          stub_active_merchant_interaction
          @reservation.reject!
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::ReservationWorkflow::Rejected.new(@reservation.id))
          assert_equal '+1987654421', sms.to
          assert sms.body =~ Regexp.new("Your booking for #{@reservation.transactable.name} was declined. View booking:"), "wrong body: #{sms.body}"
          assert sms.body =~ /http:\/\/goo.gl/, "Sms body does not include http://goo.gl: #{sms.body}"
          assert_not_contains 'Liquid error:', sms.body
          assert_not_contains 'translation missing:', sms.body
        end
      end

      context '#notify_guest_of_host_cancel_sms' do
        setup do
          @reservation_creator.notify_guest_reservation_host_cancel_sms!
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerCancelled, @reservation.id)
        end

        should 'render with the reservation' do
          @reservation.stubs(:schedule_refund).returns(true)
          @reservation.stubs(:cancellable?).returns(true)
          @reservation.confirm!
          @reservation.host_cancel!
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::ReservationWorkflow::ListerCancelled.new(@reservation.id))
          assert_equal '+1987654421', sms.to
          assert sms.body =~ Regexp.new("Your booking for #{@reservation.transactable.name} was cancelled. View booking:"), "wrong body: #{sms.body}"
          assert sms.body =~ /http:\/\/goo.gl/, "Sms body does not include http://goo.gl: #{sms.body}"
          assert_not_contains 'Liquid error:', sms.body
          assert_not_contains 'translation missing:', sms.body
        end
      end
    end
  end
end
