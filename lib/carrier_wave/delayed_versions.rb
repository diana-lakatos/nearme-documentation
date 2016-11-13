# frozen_string_literal: true
module CarrierWave::DelayedVersions
  extend ActiveSupport::Concern

  module ClassMethods
    def mount_uploader(column, uploader, options = {}, &blk)
      super

      # for rake db:schema:load
      return unless table_exists?

      serialize("#{column}_transformation_data", Hash) if column_names.include?("#{column}_transformation_data")

      return unless column_names.include?("#{column}_transformation_data")

      alias_method "original_#{column}_url", "#{column}_url"
      define_method "#{column}_url" do |*args|
        send(column).url(*args)
      end

      before_save do
        if changes[column].present?
          processor = CarrierWave::SourceProcessing::Processor.new(self, column)
          attributes[column.to_s] ? processor.assign_dimensions : processor.clear_meta
        end
      end

      after_commit do
        processor = CarrierWave::SourceProcessing::Processor.new(self, column)

        if previous_changes["#{column}_transformation_data"].present? && attributes["#{column}_transformation_data"] != {}
          processor.enqueue_processing
        elsif (previous_changes[column].present? || try(:force_regenerate_versions)) && attributes[column.to_s]
          if uploader.respond_to?(:delayed_versions)
            processor.enqueue_processing
          else
            processor.touch_versions_timestamp_and_callback
          end
        end
      end
    end
  end
end
