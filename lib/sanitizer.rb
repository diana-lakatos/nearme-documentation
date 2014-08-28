require 'sanitize'

class Sanitizer

  def self.sanitze(html)
    Sanitize.fragment(html, config)
  end

  private

  def self.config
    Sanitize::Config::BASIC
  end

end
