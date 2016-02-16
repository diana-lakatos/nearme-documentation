require 'sanitize'

class Sanitizer

  def self.sanitze(html)
    Sanitize.fragment(html, config)
  end

  def self.sanitize_with_options(html, options = {})
    Sanitize.fragment(html, Sanitize::Config.merge(Sanitize::Config::BASIC, options))
  end

  private

  def self.config
    Sanitize::Config::BASIC
  end

end
