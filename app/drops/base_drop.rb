# frozen_string_literal: true
class BaseDrop < Liquid::Drop
  class RoutesProxy
    class << self
      def method_missing(method_sym, *arguments, &block)
        if url_helpers.respond_to?(method_sym)
          options = arguments.last.is_a?(Hash) ? arguments.pop : {}
          options[:language] = language if language
          options[:host] = PlatformContext.current.decorate.host
          arguments << options
          url_helpers.public_send(method_sym, *arguments)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        url_helpers.respond_to?(method_name, include_private)
      end

      private

      def url_helpers
        Rails.application.routes.url_helpers
      end

      def language
        PlatformContext.current&.url_locale
      end
    end
  end

  include MoneyRails::ActionViewExtension

  # @return [Object]
  attr_reader :source

  # The drop class
  # @return [String]
  def drop_class
    self.class.to_s
  end

  def initialize(source)
    @source = source.respond_to?(:decorate) ? source.decorate : source
  end

  def errors
    @source.errors
  end

  private

  # @todo -- deprecate, DIY
  def hidden_ui_by_key(key)
    HiddenUiControls.find(key)
  end

  # @todo -- deprecate, DIY
  def hide_tab?(tab)
    key = "#{@context['params'][:controller]}/#{@context['params'][:action]}##{tab}"
    HiddenUiControls.find(key).hidden?
  end

  def routes
    RoutesProxy
  end

  def asset_url(source)
    if @context.registers[:action_view].respond_to?(:asset_url)
      @context.registers[:action_view].asset_url(source)
    else
      ActionController::Base.helpers.asset_url(source)
    end
  end

  alias image_url asset_url

  def urlify(path)
    'https://' + platform_context_decorator.host + path
  end

  def platform_context_decorator
    @platform_context_decorator ||= PlatformContext.current.decorate
  end

  def token_key
    TemporaryTokenAuthenticatable::PARAMETER_NAME
  end
end
