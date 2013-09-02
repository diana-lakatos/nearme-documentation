require 'test_helper'

class JobTest < ActiveSupport::TestCase

  class SampleMailer < DesksNearMeMailer

    def send_email

    end
  end

  context 'enqueue' do

    should 'add enqueue method to mailers that invokes MailerJob with proper arguments' do
      MailerJob.expects(:perform).with(SampleMailer, :send_email)
      SampleMailer.enqueue.send_email
    end

    should 'understand tim with zone as argument' do
      @time = Time.zone.now + 5.hours
      MailerJob.expects(:perform_later).with(@time, SampleMailer, :send_email)
      SampleMailer.enqueue_later(@time).send_email
    end

  end

  context '#get_performing_time' do
    setup do
      Timecop.freeze(Time.zone.now)
    end

    should 'accept number of seconds as argument' do
      assert_equal Time.zone.now + 1.hour, Job.get_performing_time(1.hour)
    end

    should 'accept time' do
      assert_equal Time.zone.now + 1.hour, Job.get_performing_time(1.hour.from_now)
    end

    should 'raise exception when using time' do
      assert_raise RuntimeError do
        Job.get_performing_time(Time.now) 
      end
    end

    teardown do
      Timecop.return
    end

  end

end

