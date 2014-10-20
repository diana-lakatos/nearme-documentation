require 'test_helper'

class CustomMailerTest < ActiveSupport::TestCase

  module DummyWorkflow
    class DummyStep < WorkflowStep::BaseStep

      def initialize(lister, enquirer, dummy_arg)
        @lister = lister
        @enquirer = enquirer
        @dummy_arg = dummy_arg
      end

      def lister
        @lister
      end

      def enquirer
        @enquirer
      end

      def data
        { dummy_arg: @dummy_arg }
      end

    end
  end

  class DummyArgDrop < BaseDrop
    attr_reader :dummy_arg
    delegate :name, to: :dummy_arg
    def initialize(dummy_arg)
      @dummy_arg = dummy_arg
    end
  end

  setup do
    stub_mixpanel
    @step = DummyWorkflow::DummyStep.new(stub(email: 'lister@example.com'), stub(email: 'enquirer@example.com'), stub(to_liquid: DummyArgDrop.new(stub(name: 'dummy name!'))))
    @email_template = FactoryGirl.create(:instance_view_email_text)
    @email_template = FactoryGirl.create(:instance_view_email_html)
    @layout_template = FactoryGirl.create(:instance_view_layout)
  end

  should 'be able to send email to lister' do
    WorkflowAlert.stubs(:find).returns(stub(layout_path: nil, from: 'maciek@example.com', reply_to: 'no-reply@example.com', cc: 'cc@example.com', bcc: 'bcc@example.com', template_path: @email_template.path, recipient_type: 'lister', subject: '[{{platform_context.name}}] This is {{ dummy_arg.name }} subject'))
    mail = CustomMailer.custom_mail(@step, 1)
    assert_equal ['lister@example.com'], mail.to
    assert_equal ['maciek@example.com'], mail.from
    assert_equal ['no-reply@example.com'], mail.reply_to
    assert_equal ['cc@example.com'], mail.cc
    assert_equal ['bcc@example.com'], mail.bcc
    assert_equal '[DesksNearMe] This is dummy name! subject', mail.subject
    assert_contains 'Hello dummy name!', mail.html_part.body
    assert_not_contains 'This is header!', mail.html_part.body
    assert_contains 'Hello dummy name!', mail.text_part.body
    assert_not_contains 'This is header!', mail.text_part.body
  end

  should 'be able to send email to enquirer' do
    WorkflowAlert.stubs(:find).returns(stub(layout_path: nil, reply_to: nil, from: nil, cc: nil, bcc: nil, template_path: @email_template.path, subject: 'Subject', recipient_type: 'enquirer'))
    mail = CustomMailer.custom_mail(@step, 1)
    assert_equal ['enquirer@example.com'], mail.to
  end

  should 'be able to use layout' do
    WorkflowAlert.stubs(:find).returns(stub(template_path: @email_template.path, reply_to: nil, from: nil, cc: nil, bcc: nil, recipient_type: 'lister', subject: 'Subject', layout_path: @layout_template.path))
    mail = CustomMailer.custom_mail(@step, 1)
    assert_contains 'This is header Hello dummy name! This is footer', mail.html_part.body
    assert_not_contains 'This is header Hello dummy name! This is footer', mail.text_part.body
  end

  should 'be able to include attachments' do
    WorkflowAlert.stubs(:find).returns(stub(layout_path: nil, reply_to: nil, from: nil, cc: nil, bcc: nil, template_path: @email_template.path, recipient_type: 'lister', subject: 'Subject'))
    @step.stubs(:mail_attachments).returns([{name: 'dummy_attachment', value: { content: File.read(Rails.root.join('test', 'assets', 'foobear.jpeg'))} }]).at_least_once
    mail = CustomMailer.custom_mail(@step, 1)
    assert_equal 1, mail.attachments.size
    assert_equal 'dummy_attachment', mail.attachments[0].filename
  end

end

