# frozen_string_literal: true
module Liquid
  module LiquidFilters
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::RecordIdentifier
    include CurrencyHelper
    include Liquid::Filters::DeprecatedFilters
    include Liquid::Filters::PlatformFilters
    include LiquidFormHelpers
    include MoneyRails::ActionViewExtension
    include WillPaginate::ViewHelpers
  end
end
