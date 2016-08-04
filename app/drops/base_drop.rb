class BaseDrop < Liquid::Drop
  include MoneyRails::ActionViewExtension

  attr_reader :source

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

  def hidden_ui_by_key(key)
    HiddenUiControls.find(key)
  end

  def hide_tab?(tab)
    key = "#{@context['params'][:controller]}/#{@context['params'][:action]}##{tab}"
    HiddenUiControls.find(key).hidden?
  end

  def routes
    Rails.application.routes.url_helpers
  end

  def asset_url(source)
    if @context.registers[:action_view].respond_to?(:asset_url)
      @context.registers[:action_view].asset_url(source)
    else
      ActionController::Base.helpers.asset_url(source)
    end
  end

  alias_method :image_url, :asset_url

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
