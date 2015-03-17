require 'test_helper'

class InstanceAdmin::Theme::ContentHoldersTest < ActionDispatch::IntegrationTest

  context "Content Holder" do

    should 'be displayed in layout' do
      holder = FactoryGirl.create :content_holder, name: 'HEAD'
      get root_path
      assert_equal true, response.body.include?(holder.content)
    end

      should 'not be displayed in layout' do
      holder = FactoryGirl.create :content_holder, name: 'Whatever'
      get root_path
      assert_equal false, response.body.include?(holder.content)
    end

  end

end