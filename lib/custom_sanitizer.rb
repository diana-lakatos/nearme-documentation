require 'sanitize'

class CustomSanitizer
  def initialize(config)
    @config = Sanitize::Config.merge(Sanitize::Config::BASIC, config.presence || {})
  end

  def sanitize(html)
    Sanitize.fragment(html, @config)
  end

  def strip_tags(html)
    Sanitize.fragment(html)
  end
end
