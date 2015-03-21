# Job is used to generate carrier wave versions
# it's called from initializers/carrier_wave monkey patch.
class VersionRegenerationJob < Job
  def after_initialize(object_class, object_id, field, all = true)
    @object = object_class.find(object_id)
    @field = field
    @all = all
  end

  def perform
    CarrierWave::SourceProcessing::Processor.new(@object, @field).generate_versions(@all)
  end
end
