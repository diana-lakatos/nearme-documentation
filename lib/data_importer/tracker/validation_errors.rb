class DataImporter::Tracker::ValidationErrors < DataImporter::Tracker
  def initialize
    @log_report = ''
  end

  def custom_validation_error(message)
    log(message)
  end

  def object_not_saved(object, object_name)
    log_validation_error(object, object_name)
  end

  def object_not_valid(object, object_name)
    log_validation_error(object, object_name)
  end

  def to_s
    @log_report
  end

  protected

  def log_validation_error(entity, entity_name)
    log("Validation error for #{entity.class.name} #{entity_name}: #{entity.errors.full_messages.to_sentence}. Ignoring all children.")
  end

  def log(message)
    @log_report += message + "\n"
  end
end
