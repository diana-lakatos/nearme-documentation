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

end
