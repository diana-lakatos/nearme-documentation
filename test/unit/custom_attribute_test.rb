require 'test_helper'

class CustomAttributeTest < ActiveSupport::TestCase

  context 'translations' do

    context 'input' do
      setup do
        @custom_attribute = FactoryGirl.create(:custom_attribute_input,
                                               target: FactoryGirl.build(:transactable_type, name: 'My TransactableType'),
                                               name: 'My Attribute')
      end

      should 'create translations for label' do
        label_translations_exist('My Label')
        placeholder_translations_exist('My Placeholder')
        hint_translations_exist('this is my hint')
        prompt_translation_exists(nil)
        valid_valus_translations_exist(nil)
      end

      should 'update translations on tta update' do
        assert_no_difference 'Translation.count' do
          @custom_attribute.label = 'New Label'
          @custom_attribute.placeholder = 'New Placeholder'
          @custom_attribute.hint = 'New Hint'
          @custom_attribute.save!
        end
        label_translations_exist('New Label')
        placeholder_translations_exist('New Placeholder')
        hint_translations_exist('New Hint')
        prompt_translation_exists(nil)
        valid_valus_translations_exist(nil)
      end

    end

    context 'select' do
      setup do
        @custom_attribute = FactoryGirl.create(:custom_attribute_select,
                                               target: FactoryGirl.build(:transactable_type, name: 'My TransactableType'),
                                               name: 'My Attribute')
      end

      should 'create translations for select' do
        label_translations_exist('My Label')
        placeholder_translations_exist(nil)
        hint_translations_exist('this is my hint')
        prompt_translation_exists('My Prompt')
        valid_valus_translations_exist({'value_one' => 'Value One', 'value_two' => 'Value Two'})
      end

      should 'update translations for select on tta update' do
        assert_no_difference 'Translation.count' do
          @custom_attribute.label = 'New Label'
          @custom_attribute.prompt = 'New Prompt'
          @custom_attribute.save!
        end
        label_translations_exist('New Label')
        placeholder_translations_exist(nil)
        hint_translations_exist('this is my hint')
        prompt_translation_exists('New Prompt')

        @custom_attribute.valid_values = ['New One', 'New123 Three']
        @custom_attribute.save!
        valid_valus_translations_exist({'new_one' => 'New One', 'new123_three' => 'New123 Three'})
      end

    end

    should 'create translations for textarea' do
      @custom_attribute = FactoryGirl.create(:custom_attribute_textarea,
                                             target: FactoryGirl.build(:transactable_type, name: 'My TransactableType'),
                                             name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist('My Placeholder')
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist(nil)
    end

    should 'create translations for check box' do
      @custom_attribute = FactoryGirl.create(:custom_attribute_check_box,
                                             target: FactoryGirl.build(:transactable_type, name: 'My TransactableType'),
                                             name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist(nil)
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist(nil)
    end

    should 'create translations for check_box_list' do
      @custom_attribute = FactoryGirl.create(:custom_attribute_check_box_list,
                                             target: FactoryGirl.build(:transactable_type, name: 'My TransactableType'),
                                             name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist(nil)
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist({'value_one' => 'Value One', 'value_two' => 'Value Two'})
    end

    should 'create translations for radio_buttons' do
      @custom_attribute = FactoryGirl.create(:custom_attribute_radio_buttons,
                                             target: FactoryGirl.build(:transactable_type, name: 'My TransactableType'),
                                             name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist(nil)
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist({'value_one' => 'Value One', 'value_two' => 'Value Two'})
    end

  end

  private

  def label_translations_exist(label)
    translation = Translation.where(key: @custom_attribute.label_key).first
    if label.present?
      assert translation.present?
      assert_equal label, translation.value
    else
      refute translation.present?
    end
  end

  def placeholder_translations_exist(placeholder)
    translation = Translation.where(key: @custom_attribute.placeholder_key).first
    if placeholder.present?
      assert translation.present?
      assert_equal placeholder, translation.value
    else
      refute translation.present?
    end
  end

  def hint_translations_exist(hint)
    translation = Translation.where(key: @custom_attribute.hint_key).first
    if hint.present?
      assert translation.present?
      assert_equal hint, translation.value
    else
      refute translation.present?
    end
  end

  def prompt_translation_exists(prompt)
    translation = Translation.where(key: @custom_attribute.prompt_key).first
    if prompt.present?
      assert_equal prompt, translation.value
    else
      refute translation.present?
    end
  end

  def valid_valus_translations_exist(valid_values)
    valid_values ||= {}
    if valid_values.empty?
      assert_equal 0, Translation.where('key LIKE ?', "#{@custom_attribute.translation_key_prefix}.valid_values.my_attribute.%").count
    else
      valid_values.each do |key, value|
        assert_equal value, Translation.where(key: @custom_attribute.valid_value_translation_key(key)).first.value
      end
    end
  end
end
