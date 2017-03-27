# frozen_string_literal: true
require 'test_helper'

class InstanceViewResolverTest < ActiveSupport::TestCase
  setup do
    @instance = PlatformContext.current.instance
    @resolver = InstanceViewResolver.instance
    @details = { formats: [:html], locale: [:en], handlers: [:haml], instance_id: @instance.id }
  end

  should 'not find not existent template' do
    assert @resolver.find_all('index', 'public', false, @details).empty?
  end

  should 'return a template if exists with exact details' do
    @instance_view = FactoryGirl.create(:instance_view, instance_id: @instance.id)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_kind_of ActionView::Template, template
    assert_equal "%h1\n\tHello", template.source
    assert_match(/InstanceView - \d+ - "public\/index"/, template.identifier)
    assert_equal Haml::Plugin, template.handler
    assert_equal [:html], template.formats
    assert_equal 'public/index', template.virtual_path
  end

  should 'find a default template if exact does not exist' do
    @instance_view = FactoryGirl.create(:instance_view)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_kind_of ActionView::Template, template
  end

  should 'find a default template if concrete exists for different instance' do
    @instance_view = FactoryGirl.create(:instance_view, body: 'default')
    @concrete_instance_view = FactoryGirl.create(:instance_view, body: 'concrete', instance_id: FactoryGirl.create(:instance).id)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_equal 'default', template.source
  end

  should 'prioritize concrete template if was created last' do
    FactoryGirl.create(:instance_view, body: 'default', instance: nil)
    @instance_view = FactoryGirl.create(:instance_view, body: 'concrete', instance_id: @instance.id)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_equal 'concrete', template.source
  end

  should 'prioritize concrete template if was created first' do
    @instance_view = FactoryGirl.create(:instance_view, body: 'concrete', instance_id: @instance.id)
    FactoryGirl.create(:instance_view, body: 'default', instance: nil)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_equal 'concrete', template.source
  end

  should 'not confuse templates that belong to other instance if created earlier' do
    @instance_view = FactoryGirl.create(:instance_view, body: 'this', instance_id: @instance.id)
    @instance_view_other = FactoryGirl.create(:instance_view, body: 'other', instance_id: FactoryGirl.create(:instance).id)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_equal 'this', template.source
  end

  should 'not confuse templates that belong to other instance if created later' do
    @other_instance = FactoryGirl.create(:instance)
    @details[:instance_id] = @other_instance.id
    @instance_view = FactoryGirl.create(:instance_view, body: 'this', instance_id: @instance.id)
    @instance_view_other = FactoryGirl.create(:instance_view, body: 'other', instance_id: @other_instance.id)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_equal 'other', template.source
  end

  should 'choose published template when draft coexists xx' do
    @instance_view = FactoryGirl.create(:instance_view, body: 'concrete', instance_id: @instance.id)
    FactoryGirl.create(:instance_view, body: 'drafted', instance_id: @instance.id, draft: true)
    template = @resolver.find_all('index', 'public', false, @details).first
    assert_equal 'concrete', template.source
  end
end
