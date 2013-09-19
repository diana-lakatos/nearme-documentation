module CarrierWave::InkFilePicker
  extend ActiveSupport::Concern

  included do
    before(:remove, :clear)

    # Ensure that, after removing the image data, we also clear any of the
    # related attributes on the model.
    def clear
      CarrierWave::SourceProcessing::Processor.new(model, mounted_as).clear
    end

    def any_url_exists?
      source_url || exists?
    end

    def exists?
      versions_generated?
    end

    def current_url(version = nil, *args)
      if exists? || !source_url
        args.unshift(version) if version
        self.url(*args)
      elsif source_url
        #  see https://developers.inkfilepicker.com/docs/web/#convert
        if version && dimensions[version]
          source_url + "/convert?" + { :w => dimensions[version][:width], :h => dimensions[version][:height], :fit => 'crop' }.to_query
        else
          source_url
        end
      end
    end

    def source_url
      model["#{mounted_as}_original_url"].presence
    end

    def versions_generated?
      model["#{mounted_as}_versions_generated_at"].present?
    end

  end
end
