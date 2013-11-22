require 'test_helper'

class InstanceMailerTest < ActiveSupport::TestCase
  InstanceMailer.class_eval do
    def test_mailer(platform_context)
      @interpolation = "magic"
      mail(to: "test@example.com",
           subject: "Hello #@interpolation",
           platform_context: platform_context,
           bcc: "bcc@example.com",
           from: 'from@example.com',
           subject_locals: {'interpolation' => @interpolation})
    end
  end

  setup do
    stub_mixpanel
    @platform_context = PlatformContext.new
  end
  
  context "email template exists in db" do
    setup do 
      FactoryGirl.create(:email_template, path: 'instance_mailer/test_mailer',
                         subject: 'Test {{interpolation}}', 
                         theme: @platform_context.theme,
                         reply_to: 'reply@me.com',
                         bcc: 'test@example.com')
      @mail = InstanceMailer.test_mailer(@platform_context)
    end

    should "will liquify subject" do
      assert_equal "Test magic", @mail.subject
    end

    should "assign email template assigns" do
      assert_equal ["reply@me.com"], @mail.reply_to
      assert_equal ["bcc@example.com"], @mail.bcc
      assert_equal ["from@example.com"], @mail.from
    end

    should "handle pixel based event tracking correctly" do
      Analytics::EventTracker.any_instance.expects(:pixel_track_url).with do |event_name, custom_options|
        event_name == 'Email Opened' && custom_options[:campaign] == "Test mailer" && custom_options[:template] == 'test_mailer'
      end.returns('http://api.mixpanel.com/track/?data=emailopenedevent')
      Analytics::EventTracker.any_instance.expects(:track).with('Email Sent',  { :template => 'test_mailer', :campaign => 'Test mailer'})
      mail = InstanceMailer.test_mailer(@platform_context)
      assert mail.html_part.body.include?("http://api.mixpanel.com/track/?data=emailopenedevent"), "Tracking code for Email Opened not included in #{mail.html_part.body}"
    end

  end

  context "email template doesn't exists in db" do
    setup do
      handler = ActionView::Template.registered_template_handler('liquid')
      fake_template = ActionView::Template.new('source', 'identifier', handler, {})
      ActionView::PathSet.any_instance.stubs(:find_all).returns([fake_template])
      @mail = InstanceMailer.test_mailer(@platform_context)
    end

    should "will keep original interpolated subject" do
      assert_equal "Hello magic", @mail.subject
    end

    should "will keep default reply_to email" do
      assert_equal [@platform_context.decorate.contact_email], @mail.reply_to
    end
  end

  test "use EmailResolver first" do
    assert_equal EmailResolver.instance, InstanceMailer.view_paths.first
  end

  test "fallbacks to filesystem paths" do
    InstanceMailer.view_paths[1..-1].each do |view_path|
      assert_kind_of ActionView::OptimizedFileSystemResolver, view_path
    end
  end
end

