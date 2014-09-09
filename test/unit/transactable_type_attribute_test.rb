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
    context 'input' do
      setup do
        TransactableTypeAttribute::TranslationCreator.any_instance.stubs(:should_create_translations?).returns(true)
        @tta = FactoryGirl.create(:transactable_type_attribute_input,
                                  transactable_type: TransactableType.new(name: 'My TransactableType'),
                                  name: 'My Attribute')
      end

      should 'create translations for label' do
        plural_translation = Translation.where(key: 'simple_form.labels.listings.my_attribute').first
        singular_translation = Translation.where(key: 'simple_form.labels.listing.my_attribute').first
        assert singular_translation.present?
        assert_equal 'My Label', singular_translation.value
        assert plural_translation.present?
        assert_equal 'My Label', plural_translation.value
      end

      should 'create translations for placeholders' do
        plural_translation = Translation.where(key: 'simple_form.placeholders.listings.my_attribute').first
        singular_translation = Translation.where(key: 'simple_form.placeholders.listing.my_attribute').first
        assert singular_translation.present?
        assert_equal 'My Placeholder', singular_translation.value
        assert plural_translation.present?
        assert_equal 'My Placeholder', plural_translation.value
      end

      should 'create translations for hints' do
        plural_translation = Translation.where(key: 'simple_form.hints.listings.my_attribute').first
        singular_translation = Translation.where(key: 'simple_form.hints.listing.my_attribute').first
        assert singular_translation.present?
        assert_equal 'this is my hint', singular_translation.value
        assert plural_translation.present?
        assert_equal 'this is my hint', plural_translation.value
      end

      should 'not create translations for prompt' do
        assert_nil Translation.where(key: 'simple_form.prompts.my_transactable_type.my_attribute').first
      end


      should 'update translations on tta update' do
        assert_no_difference 'Translation.count' do
          @tta.label = 'New Label'
          @tta.placeholder = 'New Placeholder'
          @tta.hint = 'New Hint'
          @tta.save!
          assert_equal 'New Label', Translation.where(key: 'simple_form.labels.listing.my_attribute').first.value
          assert_equal 'New Label', Translation.where(key: 'simple_form.labels.listings.my_attribute').first.value
          assert_equal 'New Placeholder', Translation.where(key: 'simple_form.placeholders.listing.my_attribute').first.value
          assert_equal 'New Placeholder', Translation.where(key: 'simple_form.placeholders.listings.my_attribute').first.value
          assert_equal 'New Hint', Translation.where(key: 'simple_form.hints.listing.my_attribute').first.value
          assert_equal 'New Hint', Translation.where(key: 'simple_form.hints.listings.my_attribute').first.value
        end
      end

      should 'destroy hints translation if blank' do
        assert_difference 'Translation.count', -2 do
          @tta.hint = ''
          @tta.save!
        end
        assert_nil Translation.where(key: 'simple_form.hints.listing.my_attribute').first
        assert_nil Translation.where(key: 'simple_form.hints.listings.my_attribute').first
      end
    end

    context 'select' do
      setup do
        TransactableTypeAttribute::TranslationCreator.any_instance.stubs(:should_create_translations?).returns(true)
        @tta = FactoryGirl.create(:transactable_type_attribute_select,
                                  transactable_type: TransactableType.new(name: 'My TransactableType'),
                                  name: 'My Attribute')
      end

      should 'create translations for label' do
        plural_translation = Translation.where(key: 'simple_form.labels.listings.my_attribute').first
        singular_translation = Translation.where(key: 'simple_form.labels.listing.my_attribute').first
        assert singular_translation.present?
        assert_equal 'My Label', singular_translation.value
        assert plural_translation.present?
        assert_equal 'My Label', plural_translation.value
      end

      should 'not create translations for placeholders' do
        assert_nil Translation.where(key: 'simple_form.placeholders.listings.my_attribute').first
        assert_nil Translation.where(key: 'simple_form.placeholders.listing.my_attribute').first
      end

      should 'create translations for hints' do
        plural_translation = Translation.where(key: 'simple_form.hints.listings.my_attribute').first
        singular_translation = Translation.where(key: 'simple_form.hints.listing.my_attribute').first
        assert singular_translation.present?
        assert_equal 'this is my hint', singular_translation.value
        assert plural_translation.present?
        assert_equal 'this is my hint', plural_translation.value
      end

      should 'create translations for prompt' do
        assert_equal 'My Prompt', Translation.where(key: 'simple_form.prompts.my_transactable_type.my_attribute').first.value
      end

      should 'create translations for valid values' do
        assert_equal 'Value One', Translation.where(key: 'simple_form.valid_values.my_transactable_type.my_attribute.value_one').first.value
        assert_equal 'Value Two', Translation.where(key: 'simple_form.valid_values.my_transactable_type.my_attribute.value_two').first.value
      end

      should 'update translations on tta update' do
        assert_no_difference 'Translation.count' do
          @tta.label = 'New Label'
          @tta.prompt = 'New Prompt'
          @tta.save!
          assert_equal 'New Label', Translation.where(key: 'simple_form.labels.listing.my_attribute').first.value
          assert_equal 'New Label', Translation.where(key: 'simple_form.labels.listings.my_attribute').first.value
          assert_equal 'New Prompt', Translation.where(key: 'simple_form.prompts.my_transactable_type.my_attribute').first.value
        end
        assert_difference 'Translation.count', 2 do
          @tta.valid_values = ['New One', 'New Two']
          @tta.save!
          assert_equal 'New One', Translation.where(key: 'simple_form.valid_values.my_transactable_type.my_attribute.new_one').first.value
          assert_equal 'New Two', Translation.where(key: 'simple_form.valid_values.my_transactable_type.my_attribute.new_two').first.value
        end
      end

      should 'destroy hints translation if blank' do
        assert_difference 'Translation.count', -2 do
          @tta.hint = ''
          @tta.save!
        end
        assert_nil Translation.where(key: 'simple_form.hints.listing.my_attribute').first
        assert_nil Translation.where(key: 'simple_form.hints.listings.my_attribute').first
      end
    end

  end
end

