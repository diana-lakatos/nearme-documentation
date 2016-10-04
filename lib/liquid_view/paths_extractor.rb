# frozen_string_literal: true
class LiquidView
  class PathsExtractor
    class << self
      def paths(view_options = {})
        return Array(view_options[:template]) if view_options[:prefixes].blank?
        view_options[:prefixes].map { |prefix| "#{prefix}/#{view_options[:template]}" }
      end
    end
  end
end
