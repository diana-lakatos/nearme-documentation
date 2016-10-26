require 'test_helper'

class InstanceMailerTest < ActiveSupport::TestCase
  InstanceMailer.class_eval do
    def test_mailer
      @interpolation = 'magic'
      mail(to: 'test@example.com',
           subject: "Hello #{@interpolation}",
           bcc: 'bcc@example.com',
           reply_to: 'reply@me.com',
           from: 'from@example.com',
           subject_locals: { 'interpolation' => @interpolation })
    end
  end

  setup do
    FactoryGirl.create(:instance_view_email_text, path: 'instance_mailer/test_mailer')
    FactoryGirl.create(:instance_view_email_html, path: 'instance_mailer/test_mailer')
  end

  context 'email template exists in db' do
    setup do
      @mail = InstanceMailer.test_mailer
    end

    should 'assign email template assigns' do
      assert_equal ['reply@me.com'], @mail.reply_to
      assert_equal ['bcc@example.com'], @mail.bcc
      assert_equal ['from@example.com'], @mail.from
    end
  end

  context "email template doesn't exists in db" do
    setup do
      handler = ActionView::Template.registered_template_handler('liquid')
      fake_template = ActionView::Template.new('source', 'identifier', handler, {})
      ActionView::PathSet.any_instance.stubs(:find_all).returns([fake_template])
      @mail = InstanceMailer.test_mailer
    end

    should 'will keep original interpolated subject' do
      assert_equal 'Hello magic', @mail.subject
    end
  end

  test 'use InstanceView first' do
    assert_equal InstanceViewResolver.instance, InstanceMailer.view_paths.first
  end

  test 'fallbacks to filesystem paths' do
    assert_kind_of ActionView::OptimizedFileSystemResolver, InstanceMailer.view_paths[1]
  end
end
