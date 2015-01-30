require 'test_helper'

class InstanceViewResolverTest < ActiveSupport::TestCase

  setup do
    @instance = PlatformContext.current.instance
    @instance_type = PlatformContext.current.instance_type
    @resolver = InstanceViewResolver.instance
    @details = { formats: [:html], locale: [:en], handlers: [:haml], instance_id: @instance.id, instance_type_id: @instance_type.id  }
  end

  should 'not find not existent template' do
    assert @resolver.find_all("index", "public", false, @details).empty?
  end

  should 'return a template if exists with exact details' do
    @instance_view = FactoryGirl.build(:instance_view)
    @instance_view.instance_id = @instance.id
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_kind_of ActionView::Template, template
    assert_equal "%h1\n\tHello", template.source
    assert_match(/InstanceView - \d+ - "public\/index"/, template.identifier)
    assert_equal Haml::Plugin, template.handler
    assert_equal [:html], template.formats
    assert_equal "public/index", template.virtual_path
  end

  should 'find a default template if exact does not exist' do
    @instance_view = FactoryGirl.create(:instance_view)
    template = @resolver.find_all("index", "public", false, @details).first
    assert_kind_of ActionView::Template, template
  end

  should 'find a default template if concrete exists for different instance' do
    @instance_view = FactoryGirl.create(:instance_view, body: 'default')
    FactoryGirl.create(:instance_view, :body => 'default')
    @default_instance_view = FactoryGirl.build(:instance_view, :body => 'concrete')
    @default_instance_view.instance_id = FactoryGirl.create(:instance).id
    @default_instance_view.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "default", template.source
  end

  should 'prioritize concrete template if was created last' do
    FactoryGirl.create(:instance_view, :body => 'default')
    @default_instance_view = FactoryGirl.build(:instance_view, :body => 'concrete')
    @default_instance_view.instance_type_id = @instance_type.id
    @default_instance_view.save!
    @instance_view = FactoryGirl.build(:instance_view, :body => 'concrete')
    @instance_view.instance_id = @instance.id
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "concrete", template.source
  end

  should 'prioritize concrete template if was created first' do
    @instance_view = FactoryGirl.build(:instance_view, :body => 'concrete')
    @instance_view.instance_id = @instance.id
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    FactoryGirl.create(:instance_view, :body => 'default')
    @default_instance_view = FactoryGirl.build(:instance_view, :body => 'concrete')
    @default_instance_view.instance_type_id = @instance_type.id
    @default_instance_view.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "concrete", template.source
  end

  should 'not confuse templates that belong to other instance if created earlier' do
    @instance_view = FactoryGirl.build(:instance_view, :body => 'this')
    @instance_view.instance_id = @instance.id
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    @instance_view_other = FactoryGirl.build(:instance_view, :body => 'other')
    @instance_view_other.instance_id = FactoryGirl.create(:instance).id
    @instance_view_other.instance_type_id = @instance_type.id
    @instance_view_other.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "this", template.source
  end

  should 'not confuse templates that belong to other instance if created later' do
    @other_instance = FactoryGirl.create(:instance)
    @details[:instance_id] = @other_instance.id
    @instance_view = FactoryGirl.build(:instance_view, :body => 'this')
    @instance_view.instance_id = @instance.id
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    @instance_view_other = FactoryGirl.build(:instance_view, :body => 'other')
    @instance_view_other.instance_id = @other_instance.id
    @instance_view_other.instance_type_id = @instance_type.id
    @instance_view_other.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "other", template.source
  end

  should 'not confuse default templates that belong to other instance_type if created ealier' do
    @instance_view = FactoryGirl.build(:instance_view, :body => 'correct')
    @instance_view.instance_id = nil
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    @instance_view_other = FactoryGirl.build(:instance_view, :body => 'wrong')
    @instance_view_other.instance_id = nil
    @instance_view_other.instance_type_id = FactoryGirl.create(:instance_type).id
    @instance_view_other.save!
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "correct", template.source
  end

  should 'not confuse default templates that belong to different instance_type if created later' do
    @other_instance_type = FactoryGirl.create(:instance_type)
    @details[:instance_type_id] = @other_instance_type.id
    @instance_view = FactoryGirl.build(:instance_view, :body => 'wrong')
    @instance_view.instance_id = nil
    @instance_view.instance_type_id = @instance_type.id
    @instance_view.save!
    @instance_view_other = FactoryGirl.build(:instance_view, :body => 'correct')
    @instance_view_other.instance_id = nil
    @instance_view_other.instance_type_id = @other_instance_type.id
    @instance_view_other.save!
    @details[:instance_type_id] = @other_instance_type.id
    template = @resolver.find_all("index", "public", false, @details).first
    assert_equal "correct", template.source
  end

end

