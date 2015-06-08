require 'test_helper'

class InstanceAdmin::Theme::ContentHoldersTest < ActionDispatch::IntegrationTest

  context "Content Holder" do

    should 'be displayed in layout' do
      holder = FactoryGirl.create :content_holder, name: 'HEAD'
      get root_path
      assert response.body.include?(holder.content)
    end

    should 'not be displayed in layout' do
      holder = FactoryGirl.create :content_holder, name: 'Whatever'
      get root_path
      refute response.body.include?(holder.content)
    end

    context 'in liquid templates' do
      should 'be displayed in footer' do
        FactoryGirl.create(:content_holder, name: 'liquid holder', content: "{{ platform_context.address }} and whatever")
        theme = PlatformContext.current.theme
        theme.update_attributes! address: "super address from holder"
        PlatformContext.current.instance.instance_views.where(path: 'layouts/theme_footer').delete_all
        FactoryGirl.create(:instance_view_footer, body: "{% inject_content_holder liquid holder %}", instance: PlatformContext.current.instance)
        get root_path
        # TODO: uncomment
        #assert response.body.include?("super address from holder and whatever")
      end
    end

  end

end
