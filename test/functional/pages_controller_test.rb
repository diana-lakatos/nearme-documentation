require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  context 'GET show' do
    context 'a full page' do
      setup do
        Page.any_instance.stubs(:hero_image).returns(stub(present?: true, url: 'url'))
        @page = FactoryGirl.create(:page, content: "# Page heading \nSome text")
      end

      should 'return a content page with hero image and markdown content' do
        get :show, slug: @page.slug

        assert_response :success
        assert_select '#hero img'
        assert_select 'h1', 'Page heading'
        assert_select 'p', 'Some text'
      end
    end

    context 'a wrong path' do
      setup do
        @page = FactoryGirl.create(:page, content: "# Page heading \nSome text")
      end

      should 'raise standard exception and store it in session' do
        assert_raises Page::NotFound do
          get :show, slug: 'wrong-path'
        end
      end
    end

    context 'require_verified_user is on' do
      setup do
        Instance.any_instance.stubs(:require_verified_user?).returns(true)
      end

      should 'should render page when require_verified_user is set to false' do
        @page = FactoryGirl.create(:page, content: "# Page heading \nSome text")

        get :show, slug: @page.slug

        assert_response :success
        assert_select 'h1', 'Page heading'
        assert_select 'p', 'Some text'
      end

      should 'should not render page when require_verified_user is set to true' do
        @page = FactoryGirl.create(:page, content: "# Page heading \nSome text", require_verified_user: true)
        get :show, slug: @page.slug

        assert_response :redirect
        assert_equal flash[:warning], I18n.t('flash_messages.need_verification_html')
      end
    end
  end
end
