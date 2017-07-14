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
          get :show, slug: 'my-path-wrong'
          assert_equal 404, response.status
        end

        should 'not find path even if initial slug matches' do
          get :show, slug: 'my-path', slug2: 'wrong'
          assert_equal 404, response.status
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
          get :show, slug: 'my%'
          assert_equal 404, response.status
        end
      end

      context 'second level nested' do
        setup do
          @page = FactoryGirl.create(:page, slug: 'my-path', max_deep_level: 2, content: "# Page heading \nSome text")
        end

        should 'raise standard exception and store it in session' do
          get :show, slug: 'my-path-wrong'
          assert_equal 404, response.status
        end

        should 'find path with additional slug' do
          assert_nothing_raised do
            get :show, slug: 'my-path', slug2: 'correct'
          end
        end

        should 'not find path with third level slug' do
          get :show, slug: 'my-path', slug2: 'correct', slug3: 'wrong'
          assert_equal 404, response.status
        end

        should 'find exact match' do
          assert_nothing_raised do
            get :show, slug: 'my-path'
          end
        end
      end
    end

    context 'json page' do
      should 'render a json' do
        page = FactoryGirl.create(:page, content: { foo: :bar }.to_json, format: :json)

        get :show, slug: page.slug, format: :json

        assert_response :success
        assert_equal 'bar', JSON.parse(response.body).fetch('foo')
        assert_equal "application/json", @response.content_type
      end

      should 'render json from graph' do
        topic = FactoryGirl.create(:topic)
        FactoryGirl.create(:graph_query, name: 'topics', query_string: '{ topics{ name } }')
        template = '{% query_graph topics, result_name: g %} {{ g | json }}'
        page = FactoryGirl.create(:page, content: template, format: :json)

        get :show, slug: page.slug, format: :json

        assert_response :success
        assert_equal topic.name, JSON.parse(response.body).dig('topics', 0, 'name')
      end

      should 'render json page when there is also html one' do
        page = FactoryGirl.create(:page, content: 'hello')
        page_json = FactoryGirl.create(:page, content: { foo: :bar }.to_json, format: :json, slug: page.slug)

        get :show, slug: page.slug, format: :json

        assert_equal page.slug, page_json.slug
        assert_response :success
        assert_equal 'bar', JSON.parse(response.body).fetch('foo')
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

    context 'errors' do
      should 'store when liquid has syntax error' do
        @page = FactoryGirl.create(:page, content: '<div class="page-test">hello world {% fooooo bar %}</div>')
        MarketplaceErrorLogger::ActiveRecordLogger.any_instance.expects(:log_issue).once

        get :show, slug: @page.slug

        assert response.body.include?(Liquify::LiquidTemplateParser::LIQUID_ERROR)
      end

      should 'store when liquid runtime error' do
        @page = FactoryGirl.create(:page, content: '<div class="page-test">
        fooo
        {% query_graph foo_query, result_name: g %}
        </div>')

        get :show, slug: @page.slug

        assert_response :success
        assert response.body.include?('foo')
        assert response.body.include?('Liquid error: internal')
        assert MarketplaceError.last.message.include?('foo_query.graphql')
      end
    end
  end
end
