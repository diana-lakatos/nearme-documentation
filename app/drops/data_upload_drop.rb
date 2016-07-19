class DataUploadDrop < BaseDrop

  attr_reader :data_upload

  # csv_file_identifier
  #   name of csv file as string
  # uploader
  #   user uploading the file as a user object
  delegate :csv_file_identifier, :transactable_type, :parsing_result_log, :uploader, :parse_summary_html, to: :data_upload
  # bookable_noun
  #   noun describing the entity that can be booked as a string
  delegate :bookable_noun, to: :transactable_type

  def initialize(data_upload)
    @data_upload = data_upload
  end

  # date and time at which the upload started as string
  def import_started_at
    @data_upload.imported_at.present? ? I18n.l(@data_upload.imported_at, format: :long) : ''
  end

  # date and time at which the upload finished as string
  def import_finished_at
    I18n.l(@data_upload.updated_at, format: :long)
  end

  # the parsing result log as an HTML string
  def parsing_result_log_html
    parsing_result_log.try(:gsub, "\n", "<br />")
  end

  # the parsing result log containing the result of the parsing as a string
  # can be nil
  def parsing_result_log
    @data_upload.parsing_result_log.blank? ? nil : @data_upload.parsing_result_log.strip
  end

  # parse summary as a string showing how many objects from each category have been created
  def new_parse_summary
    @data_upload.parse_summary[:new].map { |k, v| "#{k.to_s.humanize}: #{v}"}.join(', ')
  end

  # parse summary as a string showing how many objects from each category have been updated
  def updated_parse_summary
    @data_upload.parse_summary[:updated].map { |k, v| "#{k.to_s.humanize}: #{v}"}.join(', ')
  end

  # parse summary as a string showing how many objects from each category have been deleted
  def deleted_parse_summary
    @data_upload.parse_summary[:deleted].present? ? @data_upload.parse_summary[:deleted].map { |k, v| "#{k.to_s.humanize}: #{v}"}.join(', ') : nil
  end

  # url to create a new object of the type just imported
  def new_importable_url
    case @data_upload.importable
    when TransactableType
      routes.new_dashboard_company_transactable_type_transactable_path(@data_upload.importable)
    else
      raise TypeError
    end
  end

  # Encountered error (if present) for the upload
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

