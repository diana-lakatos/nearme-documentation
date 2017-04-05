module CommunityValidators
  extend ActiveSupport::Concern

  included do
    validate :validate_community_custom_fields

    def validate_community_custom_fields
      if PlatformContext.current.try(:instance).try(:is_community?)
        if properties.respond_to?(:video_url) && properties.video_url.present?
          video_embedder = Videos::VideoEmbedder.new(properties.video_url)
          if video_embedder.html.blank?
            properties.errors.add(:video_url, I18n.t('custom_errors.video_url_not_supported'))
          end
        end
      end
    end
  end
end
