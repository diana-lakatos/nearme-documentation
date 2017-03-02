require 'test_helper'

class LiquidViewServiceTest < ActiveSupport::TestCase

  context 'create' do
    setup do
      @service_class = LiquidViewService::Create
    end

    context 'with valid params' do
      setup do
        @valid_params = { body: 'Hello', path: 'example/path', locales: Locale.all }
        @liquid_view = @service_class.new(@valid_params).call
      end

      should 'create new liquid' do
        assert @liquid_view.id.present?
        assert_equal @liquid_view.body, @valid_params[:body]
        assert_equal @liquid_view.path, @valid_params[:path]
        assert_equal @liquid_view.locales, @valid_params[:locales]
      end

      should 'set default params' do
        assert_equal @liquid_view.format, 'html'
        assert_equal @liquid_view.handler, 'liquid'
        assert_equal @liquid_view.view_type, InstanceView::VIEW_VIEW
      end
    end

    context 'with invalid params' do
      should 'set basic errros' do
        @liquid_view = @service_class.new({}).call
        assert_equal @liquid_view.errors.full_messages, [
          "Body can't be blank",
          "Path can't be blank",
          'Locales is too short (minimum is 1 character)'
        ]
      end

      should 'valid liquid syntax' do
        @liquid_view = @service_class.new(body: 'Hello {{', path: 'example_path', locales: Locale.all).call
        assert_equal @liquid_view.errors.full_messages, [
          "Body syntax is invalid (Liquid syntax error: Variable '{{' was not properly terminated with regexp: /\\}\\}/)"
        ]
      end

      should 'set no errors for custom liquid_tags' do
        @liquid_view = @service_class.new(body: '{% inject_content_holder %}', path: 'example_path', locales: Locale.all).call
        assert_equal @liquid_view.errors.count, 0
      end
    end
  end

  context 'update' do
    context 'with valid params' do
      setup do
        @service = LiquidViewService::Builder.new create(:instance_view_footer)
        @valid_update_params = { body: 'New body', path: 'new_example/path' }
        @updated_liquid_view = @service.call @valid_update_params
      end

      should 'update liquid view' do
        assert_equal @updated_liquid_view.body, @valid_update_params[:body]
      end

      should 'not update path attribute' do
        assert_not_equal @updated_liquid_view.path, @valid_update_params[:path]
      end
    end

    context 'manage drafts' do
      setup do
        @liquid_view = create(:instance_view_footer)
        @service = LiquidViewService::Builder.new @liquid_view
      end

      should 'create draft' do
        updated_liquid_view = @service.call draft: true

        assert updated_liquid_view.draft?
        refute @liquid_view.draft?
        assert_equal updated_liquid_view.locales, @liquid_view.locales
        assert_equal updated_liquid_view.transactable_types, @liquid_view.transactable_types
      end

      should 'publish draft xx' do
        draft_liquid_view = @service.call draft: true

        updated_liquid_view = LiquidViewService::Builder.new(draft_liquid_view).call(draft: false)

        refute updated_liquid_view.draft?
        refute InstanceView.exists?(@liquid_view)
      end

      should 'update with invalid syntax' do
        invalid_syntax_params = { body: "{% if not @blog_instance.facebook_app_id_present? %} without-facebook {% endif %}'>", draft: true }

        draft_liquid_view = @service.call invalid_syntax_params

        refute draft_liquid_view.changed?
        assert draft_liquid_view.errors.empty?
        assert_equal draft_liquid_view.body, invalid_syntax_params[:body]
      end
    end
  end
end
