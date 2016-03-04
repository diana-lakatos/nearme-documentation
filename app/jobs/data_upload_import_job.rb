class DataUploadImportJob < Job

  include Job::LongRunning

  def after_initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def perform
    @data_upload = DataUpload.find(@data_upload_id)
    if @data_upload.queued?
      @data_upload.import!
      @synchronizer = @data_upload.sync_mode ? DataImporter::Synchronizer.new : DataImporter::NullSynchronizer.new
      @inviter = @data_upload.send_invitational_email ? DataImporter::Inviter.new : DataImporter::NullInviter.new
      @validation_errors_tracker = DataImporter::Tracker::ValidationErrors.new
      @summary_tracker = DataImporter::Tracker::Summary.new
      xml_path = @data_upload.xml_file.proper_file_path
      @progress_tracker = DataImporter::Tracker::ProgressTracker.new(@data_upload, DataImporter::XmlEntityCounter.new(xml_path).all_objects_count)
      @trackers = [@validation_errors_tracker, @summary_tracker, @progress_tracker]
      @xml_file = DataImporter::XmlFile.new(xml_path, @data_upload.importable, {synchronizer: @synchronizer, trackers: @trackers, inviter: @inviter })
      begin
        @xml_file.parse
        @validation_errors_tracker.to_s.blank? && @data_upload.parsing_result_log.present? ? @data_upload.finish : @data_upload.finish_with_validation_errors
      rescue
        @data_upload.encountered_error = "#{$!.inspect}\n\n#{$@[0..5]}"
        @data_upload.failure
      ensure
        unless @data_upload.parsing_result_log.blank?
          @data_upload.parsing_result_log << "\n" << @validation_errors_tracker.to_s
        else
          @data_upload.parsing_result_log = @validation_errors_tracker.to_s
        end
        @data_upload.parse_summary = { new: @summary_tracker.new_entities, updated: @summary_tracker.updated_entities, deleted:  @summary_tracker.deleted_entities}
        @data_upload.save!
        @data_upload.touch(:imported_at)
      end
    end
    if @data_upload.succeeded? || @data_upload.partially_succeeded?
      WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Finished, @data_upload.id)
    elsif @data_upload.failed?
      WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Failed, @data_upload.id)
    end
  end

end
