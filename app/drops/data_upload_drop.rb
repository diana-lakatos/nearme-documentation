class DataUploadDrop < BaseDrop

  attr_reader :data_upload

  delegate :csv_file_identifier, :transactable_type, :parsing_result_log, :uploader, :parse_summary_html, to: :data_upload
  delegate :bookable_noun, to: :transactable_type

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

  def new_importable_url
    case @data_upload.importable
    when TransactableType
      routes.new_dashboard_company_transactable_type_transactable_path(@data_upload.importable)
    when Spree::ProductType
      routes.new_dashboard_product_type_product_path(@data_upload.importable)
    else
      raise TypeError
    end
  end

end

