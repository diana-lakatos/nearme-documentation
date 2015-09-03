require 'test_helper'

class TaggableTest < ActiveSupport::TestCase

  class TaggableModel < ActiveRecord::Base
    auto_set_platform_context
    scoped_to_platform_context
    self.table_name = "user_blog_posts"
    attr_accessor :name, :user

    include Taggable
  end

  context 'callbacks' do
    should 'set_tag_ownership' do
      assert_equal 0, Tag.count
      assert_equal 0, Tagging.count

      user = FactoryGirl.create(:user)
      object = TaggableModel.create(name: "Taggable", user: user, tag_list: "a,b,c")
      
      Tagging.find_each {|tagging| assert_equal tagging.tagger_id, user.id }
      assert_equal 3, Tag.count
    end
  end

  context 'class methods' do
    should '.tags' do
      assert Tag.count, 0

      tagger1 = FactoryGirl.create(:user)
      tagger2 = FactoryGirl.create(:user)

      object = TaggableModel.create(
        name: "Random name", 
        user: tagger1,
        tag_list: "a,b,c"
      )

      object2 = TaggableModel.create(
        name: "Another name", 
        user: tagger2,
        tag_list: "x,y,z"
      )

      assert_equal 6, TaggableModel.tags.count
      assert_equal 3, TaggableModel.tags(tagger1).count
      assert_equal 3, TaggableModel.tags(tagger2).count

      object3 = TaggableModel.create(
        name: "Another name", 
        user: tagger2,
        tag_list: "a,b,c,x,y,z"
      )

      assert_equal TaggableModel.tags.count, 6
    end
  end
end
