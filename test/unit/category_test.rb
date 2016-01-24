require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  context 'should acts as nested set' do
    setup do
      @locale = Locale.first

      @category = FactoryGirl.create(:category)
      @category_child = FactoryGirl.create(:category, parent_id: @category.id)
      @category_grand_child = FactoryGirl.create(:category, parent_id: @category_child.id)
      @category_sibling = FactoryGirl.create(:category)
      @category_child.reload
      @category.reload
    end

    should 'present categories added to Transactable in liquid' do
      transactable = FactoryGirl.create(:transactable)
      transactable.transactable_type.categories << @category
      transactable.categories << @category_grand_child
      transactable.reload
      assert_equal [@category_grand_child], transactable.categories
      assert_equal ({@category.name => { 'name' => @category.translated_name, 'children' => [] }}), transactable.reload.to_liquid.categories

      @category.name = "Some new name"
      @category.save
      @category.reload
      assert_equal ({@category.name => { 'name' => @category.translated_name, 'children' => [] }}), Transactable.find(transactable.id).to_liquid.categories
    end

    should 'update children permalink' do
      @category.name = 'New name'
      @category.save
      @category.reload

      assert_equal 'new-name', @category.permalink
      assert_equal "new-name/#{@category_child.name.to_url}", @category_child.reload.permalink
    end

    should 'create familiy relations' do

      assert_equal [@category_child], @category.children
      assert_equal [@category_grand_child], @category_child.children
      assert_equal [@category_sibling], @category.siblings
      assert_equal [@category, @category_child, @category_grand_child].map(&:id).sort, @category.self_and_descendants.map(&:id).sort
    end

    should 'remove category linkings when service is removed' do
      @service_type = FactoryGirl.create(:transactable_type)
      assert_difference 'CategoryLinking.count', 4 do
        @service_type.categories << Category.all
      end
      assert_equal 4, @service_type.categories.count
      assert_difference 'CategoryLinking.count', -4 do
        @service_type.destroy
      end
      assert_equal 4, Category.count
    end

    should 'remove categories when product is removed' do
      @product_type = FactoryGirl.create(:product_type)
      @product_type.categories << Category.all
      assert_equal 4, @product_type.categories.count
      assert_difference 'CategoryLinking.count', -4 do
        @product_type.destroy
      end
    end

    should 'maintain change descendants when category move around'  do
      @category_sibling.update_attributes({ parent_id: @category.id, child_index: 1 })
      @category.reload
      assert @category.self_and_descendants.include?(@category_sibling)
      assert @category.children.include?(@category_sibling)
      assert_equal "#{@category.permalink}/#{@category_sibling.name.to_url}", @category_sibling.permalink
    end

    should 'create translation based on name' do
      assert Translation.where(value: @category.name, locale: @locale.code, key: @category.translation_key).exists?
      old_translation_key = @category.translation_key
      @category.update! name: 'New Name'
      refute Translation.where(locale: @locale.code, key: old_translation_key).exists?
      assert Translation.where(value: @category.name, locale: @locale.code, key: @category.translation_key).exists?
    end

    should 'create translations for existing categories when adding new locale' do
      @locale = FactoryGirl.create(:locale, code: 'pl')
      @category.reload
      assert_equal @category.name, @category.instance.translations.where({ locale: @locale.code, key: @category.translation_key }).first.value
    end

    should 'remove translations when category has been deleted' do
      translation = Translation.where(value: @category.name, locale: @locale.code, key: @category.translation_key).first
      assert translation.present?
      @category.destroy
      translation = Translation.where(value: @category.name, locale: @locale.code, key: @category.translation_key).first
      refute translation.present?
    end
  end
end

