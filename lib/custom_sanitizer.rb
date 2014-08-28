require 'sanitize'

class CustomSanitizer

  def initialize(config = {})
    @config = Sanitize::Config.merge(Sanitize::Config::BASIC, config)
  end

  def sanitize(html)
    Sanitize.fragment(html, @config)
  end

end
