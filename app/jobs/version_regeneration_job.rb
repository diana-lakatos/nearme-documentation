# Job is used to generate carrier wave versions
# it's called from initializers/carrier_wave monkey patch.
class VersionRegenerationJob < Job
  def after_initialize(klass_name, object_id, field, all)
    @klass_name = klass_name
    @object_id = object_id
    @field = field
    @all = all
  end

  def perform
    @object = @klass_name.constantize.find(@object_id)
    CarrierWave::SourceProcessing::Processor.new(@object, @field).generate_versions(@all)
  end
end
