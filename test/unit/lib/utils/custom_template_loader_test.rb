require 'test_helper'

class Utils::CustomTemplateLoaderTest < ActiveSupport::TestCase

  setup do
    @custom_theme = FactoryGirl.create(:custom_theme)
    @custom_template_loader = Utils::CustomTemplateLoader.new(@custom_theme, File.join(Rails.root, 'test', 'assets', 'custom_templates', 'sample_theme'))
  end

  context "load" do
    should 'load views' do
      assert_equal 0, @custom_theme.instance_views.count
      assert_difference 'InstanceView.where(custom_theme_id: @custom_theme.id).count', 5 do
        @custom_template_loader.load!
      end
      assert_equal %w(edge/case/trick home/index layouts/application listings/show search/show), @custom_theme.instance_views.pluck(:path).sort
      trick_view = @custom_theme.instance_views.where(path: 'edge/case/trick').first
      assert trick_view.partial
      assert_equal "test\n", trick_view.body
    end

    should 'load assets' do
      assert_equal 0, @custom_theme.custom_theme_assets.count
      assert_difference 'CustomThemeAsset.where(custom_theme_id: @custom_theme.id).count', 3 do
        @custom_template_loader.load!
      end
      css_file = @custom_theme.custom_theme_assets.css_files.first
      assert_equal File.read(File.join(Rails.root, 'test', 'assets', 'custom_templates', 'sample_theme', 'assets', 'css', 'application.css')), File.read(css_file.file.path)
      assert_equal 'application.css', css_file.name
    end
  end
end

