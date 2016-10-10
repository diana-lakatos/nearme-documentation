require 'test_helper'

class JobTest < ActiveSupport::TestCase
  class SampleMailer < InstanceMailer
    def send_email
    end
  end

  class DefaultQueueJob < Job
    def perform
    end
  end

  class NamedQueueJob < Job
    include Job::LongRunning

    def perform
    end
  end

  context 'enqueue' do
    should 'add enqueue method to mailers that invokes MailerJob with proper arguments' do
      MailerJob.expects(:perform).with(SampleMailer, :send_email)
      SampleMailer.enqueue.send_email
    end

    should 'understand time with zone as argument' do
      @time = Time.zone.now + 5.hours
      MailerJob.expects(:perform_later).with(@time, SampleMailer, :send_email)
      SampleMailer.enqueue_later(@time).send_email
    end
  end

  context '#get_performing_time' do
    setup do
      @time_now = Time.zone.now
    end

    should 'accept activesupport::duration as argument' do
      travel_to @time_now do
        assert_equal Time.zone.now + 1.hour, Job.get_performing_time(1.hour)
      end
    end

    should 'accept number of seconds as argument' do
      travel_to @time_now do
        assert_equal Time.zone.now + 1.hour, Job.get_performing_time(3600)
      end
    end

    should 'accept time with zone' do
      travel_to @time_now do
        assert_equal Time.zone.now + 1.hour, Job.get_performing_time(1.hour.from_now)
      end
    end

    should 'raise exception when using time' do
      travel_to @time_now do
        assert_raise RuntimeError do
          Job.get_performing_time(Time.now)
        end
      end
    end
  end

  context '#queue' do
    setup do
      DesksnearMe::Application.config.run_jobs_in_background = true
    end

    teardown do
      DesksnearMe::Application.config.run_jobs_in_background = false
    end

    should 'put job in default queue if not queue method provided' do
      DefaultQueueJob.perform
      assert_equal 'default', Delayed::Job.last.queue
    end

    should 'put job in the named queue if queue method provided' do
      NamedQueueJob.perform
      assert_equal 'long_running', Delayed::Job.last.queue
    end
  end
end
