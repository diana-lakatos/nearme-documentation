module LiquidVariableExtensions
  def render(context)
    original_text = super(context)
    if original_text.is_a?(String) && !original_text.frozen? && !original_text.is_a?(ActiveSupport::SafeBuffer)
      @custom_sanitizer ||= CustomSanitizer.new(PlatformContext.current&.instance&.custom_sanitize_config)
      @custom_sanitizer.sanitize(original_text).html_safe
    else
      original_text
    end
  end
end

class Liquid::Variable
  prepend LiquidVariableExtensions
end
