require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  context 'GET show' do

    context 'a full page' do
      setup do
        Page.any_instance.stubs(:hero_image).returns(stub({:present? => true, :url => 'url'}))
        @page = FactoryGirl.create(:page,
                                   content: "# Page heading \nSome text",
                                   theme: Instance.default_instance.theme)
      end

      should 'return a content page with hero image and markdown content' do
        get :show, :path => @page.path

        assert_response :success
        assert_select "#hero img"
        assert_select "h1", "Page heading"
        assert_select "p", "Some text"
      end
    end

    context 'a wrong path' do
      setup do
        @page = FactoryGirl.create(:page,
                                   theme: Instance.default_instance.theme,
                                   content: "# Page heading \nSome text")
      end

      should 'raise standard exception and store it in session' do
        assert_raises Page::NotFound do
          get :show, :path => 'wrong-path'
        end
      end

    end
  end
end
