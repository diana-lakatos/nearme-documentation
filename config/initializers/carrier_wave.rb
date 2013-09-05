CarrierWave.configure do |config|

  config.fog_credentials = {
    :provider                   => 'AWS',
    :aws_access_key_id          => 'AKIAI5EVP6HB47OZZXXA',
    :aws_secret_access_key      => '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'
  }

  case Rails.env
  when "production"
    config.fog_directory        = 'desksnearme.production'
    config.asset_host           = 'https://s3.amazonaws.com/desksnearme.production'
    config.storage              = :fog
  when "staging"
    config.fog_directory        = 'desksnearme.staging-prod-copy'
    config.asset_host           = 'https://s3.amazonaws.com/desksnearme.staging-prod-copy'
    config.storage              = :fog
  else
    config.storage              = :file
  end
end

# adds support for inkfilepicker automagically to carrierwave. Adds callbacks to process carrier wave versions in background
module CarrierWave
  module Mount
    alias_method :original_mount_uploader, :mount_uploader
    def mount_uploader(column, uploader=nil, options={}, &block)
      use_inkfilepicker = options.delete(:use_inkfilepicker)
      original_mount_uploader(column, uploader, options, &block)
      if use_inkfilepicker

        instance_eval <<-RUBY, __FILE__, __LINE__+1
          before_validation :set_#{column}_columns, :if => lambda { |u| u.#{column}_original_url_changed? }
          after_commit :enqueue_#{column}_processing, :if => lambda { |u| u.#{column}_previously_changed? }
        RUBY

        class_eval <<-RUBY, __FILE__, __LINE__+1
          def enqueue_#{column}_processing
            # if external url has changed, we want to remove any transformations done to previous image. %column%_versions_generated_at is used
            # to determine whether external has changed - if it is nil, we will re-download the image
            if #{column}.any_url_exists?
              VersionRegenerationJob.perform(self.class, self.id, "#{column}_generate_versions")
            end
          end

          # needed to display the right thumb after re-uploading avatar
          def set_#{column}_columns
            self.#{column}_versions_generated_at = nil 
            self.#{column}_transformation_data = nil
          end

          # recreate carrier wave versions based on external url
          # we want to re-download image only if external url has changed
          def #{column}_generate_versions
            if #{column}.exists?
              # external url has not changed, meaning we can just recreate verions
          #{column}.recreate_versions!
            else
              # external url has changed, re-download!
              self.remote_#{column}_url = #{column}_original_url
            end
            self.#{column}_versions_generated_at = Time.zone.now
            self.save!(:valdiate => false)
          end

          # only trigger when something relevant to column (uploader) has changed
          def #{column}_previously_changed?
             previous_changes.keys ? (previous_changes.keys.include?("#{column}_original_url") || previous_changes.keys.include?("#{column}_transformation_data")) : false
          end

          # to not forget about any column, this helper method sets all relevant columns to nil and remove image
          def #{column}_clear_all_data
            self.remove_#{column} = true
            self.#{column}_original_url = nil
            self.#{column}_versions_generated_at = nil
            self.#{column}_transformation_data = nil
          end

          alias_method :original_#{column}_url, :#{column}_url
          def #{column}_url(*args)
          #{column}.current_url(*args)  
          end
        RUBY
      end
    end
  end
end
