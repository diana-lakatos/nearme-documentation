require 'test_helper'

class MailerJobTest < ActiveSupport::TestCase

  def setup
    @mailer_class = mock()
    @mail = mock()
  end

  context '#perform' do

    should "send email" do
      @mailer_class.stubs(:mailer_method).returns(@mail)
      @mail.expects(:deliver)
      MailerJob.perform(@mailer_class, :mailer_method)
    end

    should "invoke mailing method with given arguments" do
      @mailer_class.stubs(:mailer_method).with(1, 2, 3).returns(@mail)
      @mailer_class.stubs(:mailer_method).with().returns(nil)
      @mail.expects(:deliver)
      MailerJob.perform(@mailer_class, :mailer_method, 1, 2, 3)
      assert_not_nil @mail
    end
  end

  context '#run_at' do

    setup do
      Timecop.freeze(Time.zone.now)
      MailerJob.stubs(:run_in_background?).returns(:true)
      @mailer_class.stubs(:respond_to?).with(:to_yaml).returns(false)
      @mailer_class.stubs(:respond_to?).with(:encode_with).returns(false)
      @mailer_class.stubs(:mailer_method).returns(@mail)
      @run_at_time = Time.zone.now + 5.hour
    end

    context 'implemented' do
      setup do
        @mailer_class.stubs(:respond_to?).with(:run_at, true).returns(true)
      end

      should 'get run_at without argument' do
        @mailer_class.stubs(:run_at).returns(@run_at_time)
        Delayed::Job.expects(:enqueue).with do |instance, params|
          instance.class == MailerJob && params == { :run_at => @run_at_time }
        end
        MailerJob.perform(@mailer_class, :mailer_method)
      end

      should 'get run_at with argument' do
        @run_at_time = Time.zone.now + 5.hour
        @mailer_class.stubs(:run_at).with(:mailer_method).returns(@run_at_time)
        Delayed::Job.expects(:enqueue).with do |instance, params|
          instance.class == MailerJob && params == { :run_at => @run_at_time }
        end
        MailerJob.perform(@mailer_class, :mailer_method)
      end
    end

    context 'not implemented' do
      setup do
        @mailer_class.stubs(:respond_to?).with(:run_at, true).returns(false)
      end

      should 'run immediately' do
        Delayed::Job.expects(:enqueue).with do |instance, params|
          instance.class == MailerJob && params == { :run_at => Time.zone.now }
        end
        MailerJob.perform(@mailer_class, :mailer_method)
      end
    end

    def teardown
      Timecop.return
    end

  end
end

