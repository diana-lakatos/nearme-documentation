# frozen_string_literal: true
module CarrierWave
  module SourceProcessing
    class Processor
      def initialize(model, field)
        @model = model
        @field = field
      end

      # if external url has changed, we want to remove any transformations done to previous image. %column%_versions_generated_at is used
      # to determine whether external has changed - if it is nil, we will re-download the image
      def enqueue_processing
        VersionRegenerationJob.perform(@model.class.name, @model.id, @field) if @model.attributes[@field.to_s]
      end

      def generate_versions
        # return if there is no persisted AR object (e.g. photo was deleted before crop job ran)
        return unless @model.persisted? || !@model.send(@field).present?

        # external url has not changed, meaning we can just recreate versions
        uploader = @model.send(@field)
        uploader.delayed_processing = true

        begin
          uploader.recreate_versions!
          touch_versions_timestamp_and_callback
        rescue ::ActiveRecord::RecordNotFound
          @model.class.with_deleted.find @model.id # check for paranoid deletetion, throw if not found
        rescue ProcessingError
          # I don't understand this code, doesn't make much sense to me. I guess @model can be instance of Theme, User etc. wtf?
          # So I just added this condition just in case, but this is meant for complete rewrite.
          @model.destroy if Photo === @model
        end

        uploader.delayed_processing = false
      end

      def touch_versions_timestamp_and_callback
        @model.update_column "#{@field}_versions_generated_at", Time.zone.now
        @model.generate_versions_callback if @model.respond_to?(:generate_versions_callback)
      end

      def assign_dimensions
        dimensions = @model.send(@field).read_original_dimensions
        @model.send("#{@field}_original_width=",  dimensions[0])
        @model.send("#{@field}_original_height=", dimensions[1])
      end

      # to not forget about any column, this helper method sets all relevant columns to nil and remove image
      def clear_meta
        %w(versions_generated_at transformation_data original_width original_height).each do |f|
          @model.send("#{@field}_#{f}=", nil)
        end
      end

      private

      def versions_generated?
        @model["#{@field}_versions_generated_at"].present?
      end
    end
  end
end
