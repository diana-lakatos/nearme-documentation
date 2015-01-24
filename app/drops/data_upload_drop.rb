class DataUploadDrop < BaseDrop

  attr_reader :data_upload

  delegate :csv_file_identifier, :parsing_result_log, :uploader,
    :parse_summary_html, to: :data_upload

  def initialize(data_upload)
    @data_upload = data_upload
  end

  def import_started_at
    I18n.l(@data_upload.imported_at, format: :long)
  end

  def import_finished_at
    I18n.l(@data_upload.updated_at, format: :long)
  end

  def parsing_result_log_html
    parsing_result_log.try(:gsub, "\n", "<br />")
  end

  def parsing_result_log
    @data_upload.parsing_result_log.blank? ? nil : @data_upload.parsing_result_log.strip
  end

  def new_parse_summary
    @data_upload.parse_summary[:new].map { |k, v| "#{k.to_s.humanize}: #{v}"}.join(', ')
  end

  def updated_parse_summary
    @data_upload.parse_summary[:updated].map { |k, v| "#{k.to_s.humanize}: #{v}"}.join(', ')
  end

  def deleted_parse_summary
    @data_upload.parse_summary[:deleted].present? ? @data_upload.parse_summary[:deleted].map { |k, v| "#{k.to_s.humanize}: #{v}"}.join(', ') : nil
  end

  def new_transactable_url
    routes.new_dashboard_transactable_type_transactable_path(@data_upload.transactable_type)
  end

end

