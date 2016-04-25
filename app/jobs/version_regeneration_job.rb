# Image delayed versions generated
class VersionRegenerationJob < Job
  include Job::HighPriority

  def self.priority
    10
  end

  def after_initialize(klass_name, object_id, field, all)
    @klass_name = klass_name
    @object_id = object_id
    @field = field
    @all = all
  end

  def perform
    @object = @klass_name.constantize.find(@object_id)
    CarrierWave::SourceProcessing::Processor.new(@object, @field).generate_versions(@all)
    if @object.is_a?(Photo) && @object.listing.present?
      @object.listing_populate_photos_metadata!
    end
  rescue ActiveRecord::RecordNotFound
    # photo was deleted
  end
end
