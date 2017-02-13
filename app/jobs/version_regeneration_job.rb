# frozen_string_literal: true
# Image delayed versions generated
class VersionRegenerationJob < Job
  include Job::HighPriority

  def self.priority
    10
  end

  def after_initialize(klass_name, object_id, field, all = nil)
    @klass_name = klass_name
    @object_id = object_id
    @field = field
    # TODO: remove @all
    @all = all
  end

  def perform
    @object = @klass_name.constantize.find(@object_id)
    CarrierWave::SourceProcessing::Processor.new(@object, @field).generate_versions
    @object.listing_populate_photos_metadata! if @object.is_a?(Photo) && @object.listing.present?

    trigger_image_updated
  rescue ActiveRecord::RecordNotFound
    Rails.logger.debug("#{@klass_name} id=#{@object_id} was deleted")
  end

  private

  def trigger_image_updated
    ElasticIndexer::ElasticUpdateJobFactory.new(@object).perform
  end
end
