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

    context 'path resolution' do

      context 'not nested' do
        setup do
          @page = FactoryGirl.create(:page, max_deep_level: 1, slug: 'my-path', content: "# Page heading \nSome text")
        end

        should 'raise standard exception and store it in session' do
          assert_raises Page::NotFound do
            get :show, slug: 'my-path-wrong'
          end
        end

        should 'not find path even if initial slug matches' do
          assert_raises Page::NotFound do
            get :show, slug: 'my-path', slug2: 'wrong'
          end
        end

        should 'find exact match' do
          assert_nothing_raised do
            get :show, slug: 'my-path'
          end
        end

        should 'find exact match but with format' do
          assert_nothing_raised do
            get :show, slug: 'my-path', format: 'html'
          end
        end

        should 'ignore special sql characters' do
          assert_raises Page::NotFound do
            get :show, slug: 'my%'
          end
        end
      end

      context 'second level nested' do
        setup do
          @page = FactoryGirl.create(:page, slug: 'my-path', max_deep_level: 2, content: "# Page heading \nSome text")
        end

        should 'raise standard exception and store it in session' do
          assert_raises Page::NotFound do
            get :show, slug: 'my-path-wrong'
          end
        end

        should 'find path with additional slug' do
          assert_nothing_raised do
            get :show, slug: 'my-path', slug2: 'correct'
          end
        end

        should 'not find path with third level slug' do
          assert_raises Page::NotFound do
            get :show, slug: 'my-path', slug2: 'correct', slug3: 'wrong'
          end
        end

        should 'find exact match' do
          assert_nothing_raised do
            get :show, slug: 'my-path'
          end
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
