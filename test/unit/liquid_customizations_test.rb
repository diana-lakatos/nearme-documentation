require 'test_helper'

class LiquidCustomizationsTest < ActiveSupport::TestCase

  context "liquid sanitizations" do
    should "test sanitization for Liquid::Variable" do
      liquid = Liquid::Template.parse('{{ "<script>" }}test')
      assert_equal "&lt;script&gt;test", liquid.render

      liquid = Liquid::Template.parse('{{ "<script>" | upcase }}test')
      assert_equal "&lt;SCRIPT&gt;test", liquid.render

      liquid = Liquid::Template.parse('{{ "<script>" | make_html_safe }}test')
      assert_equal "<script>test", liquid.render(nil, filters: [LiquidFilters])
    end
  end

end

