# frozen_string_literal: true
require 'video_info'

module Videos
  class VideoEmbedder
    include ActiveModel::Model

    validate :video_availability

    def initialize(url, embed_options = {})
      @wrapper_class = [Videos::VideoInfoWrapper,
                        Videos::FacebookVideosExtractor,
                        Videos::FallbackVideo].find { |wrapper| wrapper.usable?(url) }
      @video = @wrapper_class.new(url)

      @embed_options = embed_options
    end

    def video_url
      @video.try(:url)
    end

    def html
      @video.embed_code(@embed_options)
    end

    private

    def video_availability
      errors.add(:video_url, I18n.t('custom_errors.video_url_not_supported')) if @video.is_a?(FallbackVideo)
    end
  end
end
