require 'test_helper'

class RatingReminderJobTest < ActiveSupport::TestCase

  context "With yesterday ending reservation" do

    setup do
      @reservation = FactoryGirl.create(:past_reservation)
    end

    context 'with properly set active rating system' do

      should 'send reminder to both guest and host' do
        stub_local_time_to_return_hour(Location.any_instance, 12)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id)
        RatingReminderJob.perform(Date.current.to_s)
      end

      should 'not send any reminders while its not noon in local time zone this hour' do
        stub_local_time_to_return_hour(Location.any_instance, 7)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id).never
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id).never
        RatingReminderJob.perform(Date.current.to_s)
      end

    end

    context 'without rating system' do

      setup do
        stub_local_time_to_return_hour(Location.any_instance, 12)
      end

      should 'not send reminder to guest if host rating system and transactable rating system is disabled' do
        RatingSystem.where(subject: [RatingConstants::HOST, RatingConstants::TRANSACTABLE]).update_all(active: false)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id).never
        RatingReminderJob.perform(Date.current.to_s)
      end

      should 'not send reminder to host if guest rating system is disabled' do
        RatingSystem.where(subject: [RatingConstants::GUEST]).update_all(active: false)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id).never
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id)
        RatingReminderJob.perform(Date.current.to_s)

      end

      should 'send reminder to guest if only host rating system is disabled' do
        RatingSystem.where(subject: [RatingConstants::HOST]).update_all(active: false)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id)
        RatingReminderJob.perform(Date.current.to_s)
      end

      should 'send reminder to guest if only transactable rating system is disabled' do
        RatingSystem.where(subject: [RatingConstants::TRANSACTABLE]).update_all(active: false)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id)
        RatingReminderJob.perform(Date.current.to_s)
      end

    end
  end

  context "With a future reservation" do

    setup do
      @reservation = FactoryGirl.create(:reservation)
    end

    should 'not send any reminders while reservation didnt end yesterday' do
      stub_local_time_to_return_hour(Location.any_instance, 12)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id).never
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id).never
      RatingReminderJob.perform(Date.current.to_s)
    end

  end

  context "With an already sent reservation" do

    setup do
      @reservation = FactoryGirl.create(:past_reservation,
                                        request_guest_rating_email_sent_at: Time.zone.now,
                                        request_host_and_product_rating_email_sent_at: Time.zone.now)
    end

    should 'not send any reminders while reservation was already notified' do
      stub_local_time_to_return_hour(Location.any_instance, 12)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id).never
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id).never
      RatingReminderJob.perform(Date.current.to_s)
    end

  end

  context "With an already expired reservation" do

    setup do
      @reservation = FactoryGirl.create(:past_reservation, state: 'expired')
    end

    should 'not send any reminders to expired reservations' do
      stub_local_time_to_return_hour(Location.any_instance, 12)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestRatingRequested, @reservation.id).never
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostRatingRequested, @reservation.id).never
      RatingReminderJob.perform(Date.current.to_s)
    end

  end

end
