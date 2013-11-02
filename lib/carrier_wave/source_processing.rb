# adds support for inkfilepicker automagically to carrierwave. Adds callbacks to process carrier wave versions in background
module CarrierWave
  module SourceProcessing
    class Processor
      def initialize(model, field)
        @model, @field = model, field
      end

      # needed to display the right thumb after re-uploading avatar
      def url_was_changed
        @model["#{@field}_versions_generated_at"] = nil
        @model["#{@field}_transformation_data"] = nil
        @model["#{@field}_original_width"] = nil
        @model["#{@field}_original_height"] = nil
      end

      # if external url has changed, we want to remove any transformations done to previous image. %column%_versions_generated_at is used
      # to determine whether external has changed - if it is nil, we will re-download the image
      def enqueue_processing
        if @model.send(@field).any_url_exists?
          VersionRegenerationJob.perform(@model.class, @model.id, @field)
        end
      end

      # recreate carrier wave versions based on external url
      # we want to re-download image only if external url has changed
      def generate_versions
        # return if there is no persisted AR object (e.g. photo was deleted before crop job ran)
        return unless @model.persisted?
        
        if versions_generated? || !source_url
          # external url has not changed, meaning we can just recreate verions
          @model.send(@field).recreate_versions!
        else
          # external url has changed, re-download!
          @model.send("remote_#{@field}_url=", source_url)
          dimensions = @model.send(@field).original_dimensions
          @model.send("#{@field}_original_width=", dimensions[0])
          @model.send("#{@field}_original_height=", dimensions[1])
        end
        @model["#{@field}_versions_generated_at"] = Time.zone.now

        begin
          @model.save!(:valdiate => false)
        rescue ::ActiveRecord::RecordNotFound => e
          @model.class.with_deleted.find @model.id # check for paranoid deletetion, throw if not found
        end
      end

      # to not forget about any column, this helper method sets all relevant columns to nil and remove image
      def clear
        @model.send("remove_#{@field}=", true)

        %w(original_url versions_generated_at transformation_data original_width original_height).each do |f|
          @model.send("#{@field}_#{f}=", nil)
        end
      end

      private

      def source_url
        @model["#{@field}_original_url"]
      end

      def versions_generated?
        @model["#{@field}_versions_generated_at"].present?
      end
    end

    def mount_uploader(column, uploader, options = {}, &blk)
      use_inkfilepicker = options.delete(:use_inkfilepicker)
      super

      return unless use_inkfilepicker

      # Callbacks for field
      before_validation do
        Processor.new(self, column).url_was_changed if send("#{column}_has_changed?")
      end

      after_commit do
        Processor.new(self, column).enqueue_processing if send("#{column}_did_change?")
      end

      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}_did_change?
          changes = previous_changes.keys || []
          changes.include?("#{column}_original_url") ||
            changes.include?("#{column}_transformation_data")
        end

        def #{column}_has_changed?
          #{column}_original_url_changed?
        end

        alias_method :original_#{column}_url, :#{column}_url
        def #{column}_url(*args)
          #{column}.current_url(*args)  
        end
      RUBY
    end
  end
end
