require 'test_helper'

class EmailTemplateTest < ActiveSupport::TestCase
  context "liquid template" do
    setup do
      instance = FactoryGirl.build(:instance)
      @template = instance.email_templates.new(body: "Hello {{ email }}.", from: "me@desk.com", subject: "Hello", type: "hello_user")
      @template.valid?
    end

    should "render template" do
      actual_render   = @template.render(email: 'test@test.com')
      expected_render = "Hello test@test.com."
      assert_equal expected_render, actual_render
    end
  end
end
