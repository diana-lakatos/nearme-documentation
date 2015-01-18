require 'test_helper'

# don't use Theme::CompilerTest for this class and dont's ask me why
# if anyone will resolve this in the future, ping me please
# Josef Šimánek <josef.simanek@gmail.com>, 7.5.2014
class CompilerTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    @theme = Theme.new.skipping_compilation do |theme|
      theme.owner = @instance
      theme.contact_email = 'support@desksnear.me'
      theme.save!
    end
  end

  context '#generate_and_update_assets' do
    should 'compile a css file and save it to the Theme' do
      compiler = Theme::Compiler.new(@theme)
      compiler.generate_and_update_assets

      assert @theme.compiled_stylesheet.present?
      assert @theme.compiled_dashboard_stylesheet.present?
    end

    should 'render css rule' do
      compiler = Theme::Compiler.new(@theme)
      assert compiler.send(:render_stylesheet, 'theme.scss.erb') =~ /#logo/, "Expected to see a CSS rule"
    end
  end

  context 'theme assets' do
    setup do
      @images = %w(hero_image icon_image icon_retina_image logo_image logo_retina_image)
      @images.each do |image|
        Theme.any_instance.stubs(image.to_sym).returns(stub(url: Rails.root.join('test', 'assets', image), remove_previously_stored_files_after_update: true, original_dimensions: [100, 100]))
      end
    end

    should 'compiled css have theme assets' do
      compiler = Theme::Compiler.new(@theme)
      css = compiler.send(:render_stylesheet, 'theme.scss.erb')

      @images.each do |image|
        regexp = "url(#{Rails.root.join('test', 'assets', image)})"
        assert_match(/#{Regexp.escape(regexp)}/, css)
      end
    end
  end

  context 'theme colors' do
    setup do
      Theme::COLORS.each_with_index do |color, index|
        Theme.any_instance.stubs("color_#{color}".to_sym).returns(index.to_s*6)
        Theme.any_instance.stubs(:hex_color).with(color.to_sym).returns("##{index.to_s*6}")
      end
    end

    should 'compiled css have theme colors' do
      compiler = Theme::Compiler.new(@theme)
      css = compiler.send(:render_stylesheet, 'theme.scss.erb')

      Theme::COLORS.each_with_index do |color, index|
        assert_match Regexp.new("##{index.to_s*6}"), css
      end
    end
  end

  context 'theme logo and icon' do
    setup do
      @logos = %w(logo_image logo_retina_image)
      @icons = %w(icon_image icon_retina_image)
      @icons.each_with_index do |image, index|
        Theme.any_instance.stubs(image.to_sym).returns(stub(:url => Rails.root.join('test', 'assets', image), :remove_previously_stored_files_after_update => true, :original_dimensions => [120 * (index + 1), 45 * (index + 1)])) # height is 33% bigger
      end

      @logos.each_with_index do |image, index|
        Theme.any_instance.stubs(image.to_sym).returns(stub(:url => Rails.root.join('test', 'assets', image), :remove_previously_stored_files_after_update => true, :original_dimensions => [300 * (index + 1), 42 * (index + 1)])) # height is 40% bigger
      end
    end

    should 'compiled css have theme logos and icons' do
      compiler = Theme::Compiler.new(@theme)
      css = compiler.send(:render_stylesheet, 'theme.scss.erb')

      @icons.each_with_index do |image, index|
        assert_match Regexp.new("margin-top: #{30 - ((120 * (index + 1) * (2 / 3)) / 2)}"), css
      end

      @logos.each_with_index do |image, index|
        assert_match Regexp.new("margin-top: #{30 - ((300 * (index + 1) * (30 / 42)) / 2)}"), css
      end
    end
  end
end

