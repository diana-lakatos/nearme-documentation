require 'test_helper'
require 'footer_resolver'

class FooterResolverTest < ActiveSupport::TestCase

  def setup
    @resolver = FooterResolver.instance
    @theme = Instance.default_instance.theme
    @details  = {:formats => [:html], :locale => [:en], :handlers => [:erb, :liquid], :theme => @theme }
  end

  test "doesn't resolve a view for undefined path" do
    assert @resolver.find_all("index", "unknown", false, @details).empty?
  end

  test "resolve valid path" do
    FactoryGirl.create(:footer_template, path: 'layouts/theme_footer', body: 'content', partial: false)
    template = @resolver.find_all("theme_footer", "layouts", false, @details).first
    assert_kind_of ActionView::Template, template

    assert_equal 'content', template.source
    assert_equal LiquidView, template.handler
    assert_equal [:html], template.formats
    assert_equal "layouts/theme_footer", template.virtual_path
  end

  test "cache expire after model update" do
    db_template = FactoryGirl.create(:footer_template, path: 'layouts/theme_footer', body: 'content', partial: false)

    cache_key = Object.new
    template = @resolver.find_all("theme_footer", "layouts", false, @details, cache_key).first
    assert_equal 'content', template.source

    db_template.update_attribute(:body, 'Hi there!')

    template = @resolver.find_all("theme_footer", "layouts", false, @details, cache_key).first
    assert_equal 'Hi there!', template.source
  end
end
