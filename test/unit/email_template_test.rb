require 'test_helper'

class EmailTemplateTest < ActiveSupport::TestCase

  should belong_to(:instance)

  context "#liquid_subject" do
    should "return liquified subject" do
      template = FactoryGirl.create(:email_template, subject: 'Hello {{name}}')
      assert_equal 'Hello world', template.liquid_subject('name' => 'world')
    end
  end
end
