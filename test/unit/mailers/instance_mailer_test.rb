require 'test_helper'

class InstanceMailerTest < ActiveSupport::TestCase
  InstanceMailer.class_eval do
    def test_mailer(instance)
      @interpolation = "magic"
      mail(to: "test@example.com",
           subject: "Hello #@interpolation",
           instance: instance,
           subject_locals: {'interpolation' => @interpolation})
    end
  end

  setup do
    @instance = Instance.first || FactoryGirl.create(:instance)
  end
  
  context "email template exists in db" do
    setup do 
      FactoryGirl.create(:email_template, path: 'instance_mailer/test_mailer',
                         subject: 'Test {{interpolation}}', instance: @instance)
    end

    should "will liquify subject" do
      mail = InstanceMailer.test_mailer(@instance)

      assert_equal "Test magic", mail.subject
    end
  end

  context "email template doesn't exists in db" do
    should "will keep original interpolated subject" do
      handler = ActionView::Template.registered_template_handler('liquid')
      fake_template = ActionView::Template.new('source', 'identifier', handler, {})
      ActionView::PathSet.any_instance.stubs(:find_all).returns([fake_template])
      mail = InstanceMailer.test_mailer(@instance)

      assert_equal "Hello magic", mail.subject
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
