require 'test_helper'

class TagTest < ActiveSupport::TestCase
  context 'associations' do
    should belong_to(:instance)
  end

  context 'scopes' do
    should '.alphabetically' do
      tag1 = FactoryGirl.create(:tag, name: 'Aab')
      tag2 = FactoryGirl.create(:tag, name: 'Aaa')

      assert_equal Tag.alphabetically.pluck(:id), [tag2.id, tag1.id]
    end
  end

  context 'class methods' do
    should '.autocomplete' do
      blog_post = FactoryGirl.create(:blog_post, tag_list: 'aaa,abb,abc')

      assert_equal Tag.autocomplete('a').count, 3
      assert_equal Tag.autocomplete('ab').count, 2
      assert_equal Tag.autocomplete('abc').count, 1
      assert_equal Tag.autocomplete('x').count, 0
      assert_equal Tag.autocomplete('aaaa').count, 0
    end
  end

  context 'instance methods' do
    should '#to_liquid' do
      tag = FactoryGirl.create(:tag)
      assert_equal tag.to_liquid.class.name, 'TagDrop'
    end
  end
end
