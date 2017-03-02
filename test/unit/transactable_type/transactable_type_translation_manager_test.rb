require 'test_helper'

class TransactableType::TransactableTypeTranslationManagerTest < ActiveSupport::TestCase
  setup do
    @transactable_type = FactoryGirl.create(:transactable_type, name: 'My TT', bookable_noun: 'Chair', lessor: 'Chairman', lessee: 'Carpenter')
    @custom_attribute = FactoryGirl.create(:custom_attribute_input, target: @transactable_type, name: 'my_cust_attr', label: 'Custom Label', hint: 'Custom Hint')
  end

  should 'create proper initial translations' do
    assert_translations
  end

  should 'be able to change bookable noun' do
    assert_no_difference 'Translation.count' do
      @transactable_type.update!(bookable_noun: 'Desk')
      assert_translations(name: { one: 'Desk', other: 'Desks' })
    end
  end

  should 'prevert customized label for name' do
    assert_equal 'Name', I18n.t(custom_attribute('name').label_key)
    Translation.find_by(instance_id: @transactable_type.instance_id, locale: 'en', key: custom_attribute('name').label_key).update!(value: 'My Cool Name')
    assert_equal 'My Cool Name', I18n.t(custom_attribute('name').label_key)
    @transactable_type.update!(name: 'Desk')
    assert_equal 'My Cool Name', I18n.t(custom_attribute('name').label_key)
  end

  should 'be able to change name of transactable type' do
    @transactable_type.update!(name: 'Desk')
    assert_translations
    @transactable_type.update!(name: 'Another Desk', bookable_noun: 'Cool Desk')
    assert_translations(name: { one: 'Cool Desk', other: 'Cool Desks' })
    @custom_attribute.update!(label: 'Cool Label', hint: '')
    assert_translations(name: { one: 'Cool Desk', other: 'Cool Desks' }, label: 'Cool Label', hint: nil)
    @transactable_type.update!(name: 'Another Name', lessor: 'Cool Lessor', lessee: 'Cool Lessee')
    assert_translations(name: { one: 'Cool Desk', other: 'Cool Desks' },
                        lessor: { one: 'Cool Lessor', other: 'Cool Lessors' },
                        lessee: { one: 'Cool Lessee', other: 'Cool Lessees' },
                        label: 'Cool Label',
                        hint: nil)
  end

  should 'be able to change label and hint' do
    @custom_attribute.update!(label: 'Another Label', hint: 'Another Hint')
    assert_translations(label: 'Another Label', hint: 'Another Hint')
  end

  protected

  def assert_translations(options = {})
    options.reverse_merge!(
      name: { one: 'Chair', other: 'Chairs' },
      lessor: { one: 'Chairman', other: 'Chairmen' },
      lessee: { one: 'Carpenter', other: 'Carpenters' },
      label: 'Custom Label',
      hint: 'Custom Hint'
    )
    assert_equal(options[:name], translation_manager.find_key('name'))
    assert_equal(options[:lessor], translation_manager.find_key('lessor'))
    assert_equal(options[:lessee], translation_manager.find_key('lessee'))
    assert_equal(options[:label], I18n.t(@custom_attribute.label_key, default: '').presence)
    assert_equal(options[:hint], I18n.t(@custom_attribute.hint_key, default: '').presence) if options[:hint].present?
    @translation_manager = nil
  end

  def translation_manager
    # we do not want to cache this
    @translation_manager = TranslationManager.new(@transactable_type.reload)
  end

  def custom_attribute(field)
    CustomAttributes::CustomAttribute.new(target: @transactable_type, instance: @transactable_type.instance, html_tag: :input, name: field)
  end
end
