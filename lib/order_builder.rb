module ActiveRecord::OrderBuilder
  extend ActiveSupport::Concern

  module ClassMethods
    def can_order_by?(options)
      return false if options[:sort].blank? || column_names.exclude?(options[:sort].to_s)
      return false if options[:order].present? && !options[:order].to_s.downcase.in?(%w(asc desc))
      true
    end

    def build_order(options)
      fail ArgumentError unless can_order_by?(options)
      options[:order] ||= 'ASC'
      "#{table_name}.#{options[:sort]} #{options[:order].to_s.upcase}"
    end
  end
end
