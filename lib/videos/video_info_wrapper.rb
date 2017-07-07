# frozen_string_literal: true
module Videos
  class VideoInfoWrapper
    def self.usable?(url)
      # We must do this here as only VideoInfo itself will know what URLs it supports
      video_info = VideoInfo.new(url) rescue nil
      video_info.try(:embed_code).present?
    end

    def initialize(url)
      @url = url
      @video_info = VideoInfo.new(url)
    end

    def url
      @video_info.url
    end

    def embed_code(attributes = {})
      attributes = attributes.merge(url_attributes: { rel: 0 }) if @video_info.try(:provider) == 'YouTube'

      "<div class=\"video-wrapper #{@video_info.provider.downcase}\"><div class=\"video-constrainer\">#{@video_info.embed_code(attributes)}</div></div>"
    end
  end
end
