require 'test_helper'

class LiquidCustomizationsTest < ActiveSupport::TestCase
  context 'liquid sanitizations' do
    should 'test sanitization for Liquid::Variable' do
      liquid = Liquid::Template.parse('{{ "<script>test" | upcase }}')
      assert_equal 'TEST', liquid.render

      liquid = Liquid::Template.parse('{{ "<script>" | make_html_safe }}test')
      assert_equal '<script>test', liquid.render(nil, filters: [Liquid::LiquidFilters])
    end
  end
end
