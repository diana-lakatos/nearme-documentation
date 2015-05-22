require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  context 'should acts as nested set' do
    setup do
      @locale = FactoryGirl.create(:locale, code: 'en')

      @category = FactoryGirl.create(:category)
      @category_child = FactoryGirl.create(:category, parent_id: @category.id)
      @category_grand_child = FactoryGirl.create(:category, parent_id: @category_child.id)
      @category_sibling = FactoryGirl.create(:category)
      @category.reload
    end

    should 'create familiy relations' do
      assert_equal [@category_child], @category.children
      assert_equal [@category_grand_child], @category_child.children
      assert_equal [@category_sibling], @category.siblings
      assert_equal [@category, @category_child, @category_grand_child].map(&:id).sort, @category.self_and_descendants.map(&:id).sort
    end

    should 'remove categories when service is removed' do
      @service_type = FactoryGirl.create(:transactable_type)
      @service_type.categories << Category.all
      assert_equal 4, @service_type.categories.count
      @service_type.destroy
      assert_equal 0, Category.count
    end

    should 'remove categories when product is removed' do
      @product_type = FactoryGirl.create(:product_type)
      @product_type.categories << Category.all
      assert_equal 4, @product_type.categories.count
      @product_type.destroy
      assert_equal 0, Category.count
    end

    should 'maintain change descendants when category move around'  do
      @category_sibling.update_attributes({ parent_id: @category.id, child_index: 1 })
      @category.reload
      assert @category.self_and_descendants.include?(@category_sibling)
      assert @category.children.include?(@category_sibling)
      assert_equal "#{@category.permalink}/#{@category_sibling.name.to_url}", @category_sibling.permalink
    end

    should 'create translation based on name' do
      assert_equal @category.name, @category.instance.translations.where({ locale: @locale.code, key: @category.translation_key }).first.value
      @category.update_attribute :name, 'New Name'
      assert @category.instance.translations.where({ locale: @locale.code, key: @category.translation_key, value: 'New Name' }).any?
    end

    should 'create translations for existing categories when adding new locale' do
      @locale = FactoryGirl.create(:locale, code: 'pl')
      @category.reload
      assert_equal @category.name, @category.instance.translations.where({ locale: @locale.code, key: @category.translation_key }).first.value
    end
  end
end

