# frozen_string_literal: true
module Liquid
  class Include < Tag
    private

    # in 4.0 they dropped passing context to file_system
    # https://github.com/Shopify/liquid/pull/441
    def read_template_from_file_system(context)
      file_system = context.registers[:file_system] || Liquid::Template.file_system

      file_system.read_template_file(context.evaluate(@template_name_expr), context)
    end
  end
end
