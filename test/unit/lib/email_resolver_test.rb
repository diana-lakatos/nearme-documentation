require 'test_helper'
require 'email_resolver'

class EmailResolverTest < ActiveSupport::TestCase

  def setup
    @resolver = EmailResolver.instance
    @theme = Instance.default_instance.theme
    @details  = {:formats => [:html], :locale => [:en], :handlers => [:erb, :liquid], :theme => @theme }
  end

  test "doesn't resolve a view for undefined path" do
    assert @resolver.find_all("index", "unknown", false, @details).empty?
  end

  test "resolve valid path" do
    FactoryGirl.create(:email_template, path: 'hello/index', html_body: 'html', text_body: 'text', partial: false)
    template = @resolver.find_all("index", "hello", false, @details).first
    assert_kind_of ActionView::Template, template

    assert_equal 'html', template.source
    assert_equal LiquidView, template.handler
    assert_equal [:html], template.formats
    assert_equal "hello/index", template.virtual_path
  end

  test "resolve valid format" do
    FactoryGirl.create(:email_template, path: 'hello/index', html_body: 'html', text_body: 'text', partial: false)
    template = @resolver.find_all("index", "hello", false, @details.merge({:formats => [:text]})).first
    assert_kind_of ActionView::Template, template

    assert_equal 'text', template.source
    assert_equal LiquidView, template.handler
    assert_equal [:text], template.formats
    assert_equal "hello/index", template.virtual_path
  end

  test "cache expire after model update" do
    db_template = FactoryGirl.create(:email_template, path: 'hello/index', html_body: 'hello', text_body: 'text', partial: false)

    cache_key = Object.new
    template = @resolver.find_all("index", "hello", false, @details, cache_key).first
    assert_equal 'hello', template.source

    db_template.update_attribute(:html_body, 'Hi there!')

    template = @resolver.find_all("index", "hello", false, @details, cache_key).first
    assert_equal 'Hi there!', template.source
  end
end
