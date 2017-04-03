# frozen_string_literal: true
class UrlGenerator
  def self.url_from_params(method_sym, *arguments, &_block)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    options[:language] = language if language
    options[:host] = PlatformContext.current.decorate.host
    arguments << options
    url_helpers.public_send(method_sym, *arguments)
  end

  def self.method_missing(method_sym, *arguments, &block)
    if url_helpers.respond_to?(method_sym)
      UrlGenerator.url_from_params(method_sym, *arguments, &block)
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    url_helpers.respond_to?(method_name, include_private)
  end

  def self.language
    PlatformContext.current&.url_locale
  end

  def self.url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end
