require 'test_helper'

class DataUploadImportJobTest < ActiveSupport::TestCase

  context 'with sync mode false' do
    setup do
      @transactable_type = stub()
      @stub = stub( xml_file: stub(proper_file_path: '/some/path'),
                   transactable_type: @transactable_type,
                   :parsing_result_log= => 'hello',
                   :parse_summary= => { new: { company: 1 }, updated: { company: 2 } },
                   :save! => true,
                   sync_mode: false
                  )
      DataUpload.stubs(:find).returns(@stub)

      @synchronizer = stub()
      DataImporter::NullSynchronizer.expects(:new).returns(@synchronizer)
      @validation_errors_tracker = stub(to_s: 'hello')
      DataImporter::Tracker::ValidationErrors.expects(:new).returns(@validation_errors_tracker)
      @summary_tracker = stub(new_entities: {company: 1}, updated_entities: {company: 2})
      DataImporter::Tracker::Summary.expects(:new).returns(@summary_tracker)
      @progress_tracker = stub()
      DataImporter::Tracker::Progress.expects(:new).returns(@progress_tracker)
      @trackers = [@validation_errors_tracker, @summary_tracker, @progress_tracker]
      @xml_file_stub = stub()
      DataImporter::XmlFile.expects(:new).with('/some/path', @transactable_type, {synchronizer: @synchronizer, trackers: @trackers }).returns(@xml_file_stub)
    end

    should 'store exception which has been raised' do
      @xml_file_stub.stubs(:parse).raises(StandardError.new('*Custom exception*'))
      @stub.expects(:encountered_error=).with do |error_string|
        error_string.include?('*Custom exception*') && error_string.include?('app/jobs/data_upload_import_job.rb:')
      end
      DataUploadImportJob.perform(1)
    end

  end

end

