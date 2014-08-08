class DataImporter::Logger

  def initialize
    @log_report = ""
  end

  def log_validation_error(entity, entity_name)
    log("Validation error for #{entity.class.name} #{entity_name}: #{entity.errors.full_messages.to_sentence}. Ignoring all children.")
  end

  def to_s
    @log_report
  end

  def log(message)
    @log_report += message + "\n"
  end

  private

end
