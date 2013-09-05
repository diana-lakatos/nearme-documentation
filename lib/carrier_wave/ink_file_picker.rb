module CarrierWave::InkFilePicker
  extend ActiveSupport::Concern

  included do

    def thumbnail_dimensions
      self.class::THUMBNAIL_DIMENSIONS
    end

    # checking if something has been already uploaded - true even if versions are not generated yet
    def any_url_exists?
      self.present? || stored_original_url
    end

    # checking if something is ready for showing - false if versions are not generated yet and no original_url has been provided
    def any_url_ready?
      self.exists? || stored_original_url
    end

    def exists?
      self.present? && stored_versions_generated
    end

    def current_url(*args)
      if exists? || !stored_original_url
        self.url(*args)
      else
        get_original_url(*args)
      end
    end

    def get_original_url(version = nil, *args)
      return nil unless stored_original_url
      #  see https://developers.inkfilepicker.com/docs/web/#convert
      if version && thumbnail_dimensions[version]
        stored_original_url + "/convert?" + { :w => thumbnail_dimensions[version][:width], :h => thumbnail_dimensions[version][:height], :fit => 'crop' }.to_query
      else
        stored_original_url
      end
    end

    def original_dimensions
      if exists?
        [width, height]
      else
        FastImage.size(get_original_url)
      end
    end
  end
end
