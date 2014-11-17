class DataUploadImportJob < Job

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    @synchronizer = @data_upload.sync_mode ? DataImporter::Synchronizer.new : DataImporter::NullSynchronizer.new
    @validation_errors_tracker = DataImporter::Tracker::ValidationErrors.new
    @summary_tracker = DataImporter::Tracker::Summary.new
    @progress_tracker = DataImporter::Tracker::Progress.new(@data_upload)
    @trackers = [@validation_errors_tracker, @summary_tracker, @progress_tracker]
    @xml_file = DataImporter::XmlFile.new(@data_upload.xml_file.proper_file_path, @data_upload.transactable_type, {synchronizer: @synchronizer, trackers: @trackers })
    begin
      @xml_file.parse
    rescue
      @data_upload.encountered_error = "#{$!.inspect}\n\n#{$@}"
    ensure
      @data_upload.parsing_result_log = @validation_errors_tracker.to_s
      @data_upload.parse_summary = { new: @summary_tracker.new_entities, updated: @summary_tracker.updated_entities }
      @data_upload.save!
    end
  end

end

