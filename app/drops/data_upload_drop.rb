class DataUploadDrop < BaseDrop
  # @return [DataUpload]
  attr_reader :data_upload

  # @!method csv_file_identifier
  #   @return [String] name of csv file as string
  # @!method parsing_result_log
  #   parsing result log
  #   @return (see DataUpload#parsing_result_log)
  # @!method uploader
  #   user uploading the file as a user object
  #   @return (see DataUpload#uploader)
  delegate :csv_file_identifier, :parsing_result_log, :uploader, to: :data_upload

  # @!method bookable_noun
  #   noun describing the entity that can be booked as a string
  #   @return (see TransactableType#bookable_noun)
  delegate :bookable_noun, to: :transactable_type

  def initialize(data_upload)
    @data_upload = data_upload
  end

  # @return [String] date and time at which the upload started as string
  def import_started_at
    @data_upload.imported_at.present? ? I18n.l(@data_upload.imported_at, format: :long) : ''
  end

  # @return [String] date and time at which the upload finished as string
  def import_finished_at
    I18n.l(@data_upload.updated_at, format: :long)
  end

  # @return [String] the parsing result log as an HTML string
  def parsing_result_log_html
    parsing_result_log.try(:gsub, "\n", '<br />')
  end

  # @return [String, nil] the parsing result log containing the result of the parsing as a string
  #   can be nil
  def parsing_result_log
    @data_upload.parsing_result_log.blank? ? nil : @data_upload.parsing_result_log.strip
  end

  # @return [String] parse summary as a string showing how many objects from each category have been created
  def new_parse_summary
    @data_upload.parse_summary[:new].map { |k, v| "#{k.to_s.humanize}: #{v}" }.join(', ')
  end

  # @return [String] parse summary as a string showing how many objects from each category have been updated
  def updated_parse_summary
    @data_upload.parse_summary[:updated].map { |k, v| "#{k.to_s.humanize}: #{v}" }.join(', ')
  end

  # @return [String] parse summary as a string showing how many objects from each category have been deleted
  def deleted_parse_summary
    @data_upload.parse_summary[:deleted].present? ? @data_upload.parse_summary[:deleted].map { |k, v| "#{k.to_s.humanize}: #{v}" }.join(', ') : nil
  end

  # @return [String] url to create a new object of the type just imported
  def new_importable_url
    case @data_upload.importable
    when TransactableType
      routes.new_dashboard_company_transactable_type_transactable_path(@data_upload.importable)
    else
      fail TypeError
    end
  end

  # @return [String] encountered error (if present) for the upload
  def sanitized_encountered_error
    encountered_error = @data_upload.encountered_error.to_s
    parts = encountered_error.split(/\n/)
    if parts.length > 1
      parts[0]
    else
      encountered_error
    end
  end
end
