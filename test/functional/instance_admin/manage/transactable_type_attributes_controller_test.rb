require 'test_helper'

class InstanceAdmin::Manage::TransactableTypeAttributesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a list of transactable type attributes associated with current instance' do
      @tta = FactoryGirl.create(:transactable_type_attribute, transactable_type: @transactable_type, name: 'my_custom_attribute')
      get :index
      assert_select 'tr td', "My custom attribute"
    end
  end

  context 'create' do

    should 'create a new transactable_type' do
      assert_difference 'TransactableTypeAttribute.count', 1 do
        post :create, {"transactable_type_attribute"=>{"name"=>"new_attribute", "label"=>"attribute label", "attribute_type"=>"string", "html_tag"=>"select", "placeholder"=>"", "prompt"=>"my prompt", "default_value"=>"value5", "hint"=>"this is hint", "public"=>"1", "valid_values"=>"value1, value2, value5", "input_html_options_string"=>"class => myclass, style => color: red", "wrapper_html_options_string"=>"class => wrapper-class, style => color: blue"}}
      end
      tta = assigns(:transactable_type_attribute)
      assert_equal 'new_attribute', tta.name
      assert_equal 'attribute label', tta.label
      assert_equal 'string', tta.attribute_type
      assert_equal 'select', tta.html_tag
      assert_equal 'my prompt', tta.prompt
      assert_equal 'value5', tta.default_value
      assert_equal %w(value1 value2 value5), tta.valid_values
      assert_equal({'class' => 'myclass', 'style' => 'color: red'}, tta.input_html_options)
      assert_equal({'class' => 'wrapper-class', 'style' => 'color: blue'}, tta.wrapper_html_options)
      assert_equal @transactable_type.id, tta.transactable_type_id
      assert_equal @instance.id, tta.instance_id
    end
  end
end
