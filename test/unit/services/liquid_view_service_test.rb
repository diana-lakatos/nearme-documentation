require 'test_helper'

class LiquidViewServiceTest < ActiveSupport::TestCase
  setup do
    @service = LiquidViewService.new
  end

  context 'with valid params' do
    context 'create method' do
      setup do
        @valid_params = { body: 'Hello', path: 'example/path', locales: Locale.all }
        @liquid_view = @service.create @valid_params
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

    context 'update method' do
      setup do
        @valid_update_params = { body: 'New body', path: 'new_example/path' }
        @updated_liquid_view = @service.update create(:instance_view_footer), @valid_update_params
      end

      should 'update liquid view' do
        assert_equal @updated_liquid_view.body, @valid_update_params[:body]
      end

      should 'not update path attribute' do
        assert_not_equal @updated_liquid_view.path, @valid_update_params[:path]
      end
    end
  end

  context 'with invalid params' do
    should 'set basic errros' do
      @liquid_view = @service.create({})
      assert_equal @liquid_view.errors.full_messages, [
        "Body can't be blank",
        "Path can't be blank",
        'Locales is too short (minimum is 1 character)'
      ]
    end

    should 'valid liquid syntax' do
      @liquid_view = @service.create(body: 'Hello {{', path: 'example_path', locales: Locale.all)
      assert_equal @liquid_view.errors.full_messages, [
        "Body syntax is invalid (Liquid syntax error: Variable '{{' was not properly terminated with regexp: /\\}\\}/)"
      ]
    end

    should 'set no errors for custom liquid_tags' do
      @liquid_view = @service.create(body: '{% inject_content_holder %}', path: 'example_path', locales: Locale.all)
      assert_equal @liquid_view.errors.count, 0
    end
  end
end
