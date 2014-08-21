require 'test_helper'

class ThemeFontTest < ActiveSupport::TestCase

  setup do
    @theme_font = FactoryGirl.create(:theme_font)
  end

  context 'creating' do
    should "trigger a compilation of the theme" do
      theme_font = ThemeFont.new(theme: FactoryGirl.create(:theme_with_compilation))
      ThemeFont::FONT_TYPES.each do |font_type|
        ThemeFont::FONT_EXTENSIONS.each do |font_extension|
          theme_font.send("#{font_type}_#{font_extension}=", File.open(Rails.root.join('app', 'assets', 'fonts', "futura-regular-web.#{font_extension}"), 'rb'))
        end
      end

      CompileThemeJob.expects(:perform).with(theme_font.theme)
      theme_font.save!
    end
  end

  context 'updating' do
    should "trigger compilation of the theme after changing relevant fields" do
      @theme_font.regular_ttf = File.open(Rails.root.join('app', 'assets', 'fonts', 'futura-medium-web.ttf'), 'rb')

      CompileThemeJob.expects(:perform).with(@theme_font.theme)
      @theme_font.save!
    end

    should "not trigger compilation if no relevant fields changed" do
      CompileThemeJob.expects(:perform).never
      @theme_font.save!
    end
  end
end
