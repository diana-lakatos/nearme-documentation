# frozen_string_literal: true
module Videos
  class FacebookVideosExtractor
    attr_reader :url

    def self.usable?(url)
      strip_params(url.to_s) =~ %r{(https?://(www.)?facebook\.com\/.*/videos/.*)|
                              (https?://(www.)?facebook\.com/.*\%2Fvideos%2F)}x
    end

    def self.strip_params(url)
      match = url.match(%r{^(?<link>.+?)(\?[^\/]*)?$})
      if match
        match['link']
      else
        url
      end
    end

    def initialize(url)
      @url = Videos::FacebookVideosExtractor.strip_params(url)
    end

    def embed_code(attributes = {})
      width = attributes.dig(:iframe_attributes, :width).presence || 480
      height = attributes.dig(:iframe_attributes, :height).presence || 270

      "<div class=\"video-wrapper facebook\"><div class=\"video-constrainer\"><iframe src='https://www.facebook.com/plugins/video.php?href=#{CGI.escape(@url)}?show_text=0&width=#{width}' width='#{width}' height='#{height}' style='border:none;overflow:hidden' scrolling='no' frameborder='0' allowTransparency='true' allowFullScreen='true'></iframe></div></div>"
    end
  end
end
