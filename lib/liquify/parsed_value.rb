# frozen_string_literal: true
module Liquify
  class ParsedValue
    def initialize(value, data = {})
      @value = value
      @data = data
    end

    def to_s
      LiquidTemplateParser.new.parse(@value, @data).strip
    end
  end
end
