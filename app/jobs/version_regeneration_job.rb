# Job is used to generate carrier wave versions 
# it's called from initializers/carrier_wave monkey patch.
class VersionRegenerationJob < Job
  def initialize(object_class, object_id, processing_method)
    @object = object_class.find(object_id)
    @processing_method = processing_method
  end

  def perform
    @object.send(@processing_method)
  end
end
