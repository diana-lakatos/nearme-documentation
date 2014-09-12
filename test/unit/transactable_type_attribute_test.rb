require 'test_helper'

class TransactableTypeAttributeTest < ActiveSupport::TestCase

  context 'array values' do

    setup do
      @instance = FactoryGirl.create(:instance)
      PlatformContext.current = PlatformContext.new
      @tt = FactoryGirl.create(:transactable_type)
      @tta = FactoryGirl.create(:transactable_type_attribute_array, transactable_type: @tt)
      @transactable = FactoryGirl.build(:transactable)
    end

    should 'be able to submit strings that will be parsed as array, then save and reload array' do
      @transactable.array = 'One, Two    ,    Three,Four'
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
      @transactable.save!
      @transactable.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
      @transactable.save!
      @transactable.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
    end

    should 'be able to assign array as array' do
      @transactable.array = ['One', 'Two', 'Three', 'Four']
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
      @transactable.save!
      @transactable.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
    end

    should 'return empty array if nil' do
      @transactable.array = nil
      assert_equal [], @transactable.array

    end
  end

  context 'translations' do

    setup do
      TransactableTypeAttribute::TranslationCreator.any_instance.stubs(:should_create_translations?).returns(true)
    end

    context 'input' do
      setup do
        @tta = FactoryGirl.create(:transactable_type_attribute_input,
                                  transactable_type: TransactableType.new(name: 'My TransactableType'),
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
          @tta.label = 'New Label'
          @tta.placeholder = 'New Placeholder'
          @tta.hint = 'New Hint'
          @tta.save!
          label_translations_exist('New Label')
          placeholder_translations_exist('New Placeholder')
          hint_translations_exist('New Hint')
          prompt_translation_exists(nil)
          valid_valus_translations_exist(nil)
        end
      end

      should 'destroy hints translation if blank' do
        assert_difference 'Translation.count', -2 do
          @tta.hint = ''
          @tta.save!
        end
        hint_translations_exist(nil)
      end
    end

    context 'select' do
      setup do
        @tta = FactoryGirl.create(:transactable_type_attribute_select,
                                  transactable_type: TransactableType.new(name: 'My TransactableType'),
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
          @tta.label = 'New Label'
          @tta.prompt = 'New Prompt'
          @tta.save!
          label_translations_exist('New Label')
          placeholder_translations_exist(nil)
          hint_translations_exist('this is my hint')
          prompt_translation_exists('New Prompt')
        end
        assert_difference 'Translation.count', 2 do
          @tta.valid_values = ['New One', 'New Two']
          @tta.save!
        end
        valid_valus_translations_exist({'new_one' => 'New One', 'new_two' => 'New Two'})
      end

      should 'destroy hints translation if blank' do
        assert_difference 'Translation.count', -2 do
          @tta.hint = ''
          @tta.save!
        end
        hint_translations_exist(nil)
      end
    end

    should 'create translations for textarea' do
      @tta = FactoryGirl.create(:transactable_type_attribute_textarea,
                                transactable_type: TransactableType.new(name: 'My TransactableType'),
                                name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist('My Placeholder')
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist(nil)
    end

    should 'create translations for check box' do
      @tta = FactoryGirl.create(:transactable_type_attribute_check_box,
                                transactable_type: TransactableType.new(name: 'My TransactableType'),
                                name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist(nil)
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist(nil)
    end

    should 'create translations for check_box_list' do
      @tta = FactoryGirl.create(:transactable_type_attribute_check_box_list,
                                transactable_type: TransactableType.new(name: 'My TransactableType'),
                                name: 'My Attribute')
      label_translations_exist('My Label')
      placeholder_translations_exist(nil)
      hint_translations_exist('this is my hint')
      prompt_translation_exists(nil)
      valid_valus_translations_exist({'value_one' => 'Value One', 'value_two' => 'Value Two'})
    end

    should 'create translations for radio_buttons' do
      @tta = FactoryGirl.create(:transactable_type_attribute_radio_buttons,
                                transactable_type: TransactableType.new(name: 'My TransactableType'),
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
    label_singular_translation_exist(label)
    label_plural_translation_exist(label)
  end

  def label_singular_translation_exist(label)
    singular_translation = Translation.where(key: 'simple_form.labels.listing.my_attribute').first
    if label.present?
      assert singular_translation.present?
      assert_equal label, singular_translation.value
    else
      refute singular_translation.present?
    end
  end

  def label_plural_translation_exist(label)
    plural_translation = Translation.where(key: 'simple_form.labels.listings.my_attribute').first
    if label.present?
      assert plural_translation.present?
      assert_equal label, plural_translation.value
    else
      refute plural_translation.present?
    end
  end

  def placeholder_translations_exist(placeholder)
    placeholder_singular_translation_exist(placeholder)
    placeholder_plural_translation_exist(placeholder)
  end

  def placeholder_singular_translation_exist(placeholder)
    singular_translation = Translation.where(key: 'simple_form.placeholders.listing.my_attribute').first
    if placeholder.present?
      assert singular_translation.present?
      assert_equal placeholder, singular_translation.value
    else
      refute singular_translation.present?
    end
  end

  def placeholder_plural_translation_exist(placeholder)
    plural_translation = Translation.where(key: 'simple_form.placeholders.listings.my_attribute').first
    if placeholder.present?
      assert plural_translation.present?
      assert_equal placeholder, plural_translation.value
    else
      refute plural_translation.present?
    end
  end

  def hint_translations_exist(hint)
    hint_singular_translation_exist(hint)
    hint_plural_translation_exist(hint)
  end

  def hint_singular_translation_exist(hint)
    singular_translation = Translation.where(key: 'simple_form.hints.listing.my_attribute').first
    if hint.present?
      assert singular_translation.present?
      assert_equal hint, singular_translation.value
    else
      refute singular_translation.present?
    end
  end

  def hint_plural_translation_exist(hint)
    plural_translation = Translation.where(key: 'simple_form.hints.listings.my_attribute').first
    if hint.present?
      assert plural_translation.present?
      assert_equal hint, plural_translation.value
    else
      refute plural_translation.present?
    end
  end

  def prompt_translation_exists(prompt)
    translation = Translation.where(key: 'simple_form.prompts.my_transactable_type.my_attribute').first
    if prompt.present?
      assert_equal prompt, translation.value
    else
      refute translation.present?
    end
  end

  def valid_valus_translations_exist(valid_values)
    valid_values ||= {}
    if valid_values.empty?
      assert_equal 0, Translation.where('key LIKE ?', "simple_form.valid_values.my_transactable_type.my_attribute.%").count
    else
      valid_values.each do |key, value|
        assert_equal value, Translation.where(key: "simple_form.valid_values.my_transactable_type.my_attribute.#{key}").first.value
      end
    end
  end

end

