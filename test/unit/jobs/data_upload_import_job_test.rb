require 'test_helper'

class DataUploadImportJobTest < ActiveSupport::TestCase

  context 'mailers' do

    should 'send finish mail if succeeded' do
      @stub = mock(queued?: false, succeeded?: true, id: 1)
      DataUpload.stubs(:find).returns(@stub)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Finished, 1)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Failed, 1).never
      DataUploadImportJob.perform(1)
    end

    should 'send finish mail if partially succeeded' do
      @stub = mock(queued?: false, succeeded?: false, partially_succeeded?: true, id: 1)
      DataUpload.stubs(:find).returns(@stub)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Finished, 1)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Failed, 1).never
      DataUploadImportJob.perform(1)
    end

    should 'send fail mail if failed' do
      @stub = mock(queued?: false, succeeded?: false, partially_succeeded?: false, failed?: true, id: 1)
      DataUpload.stubs(:find).returns(@stub)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Finished, 1).never
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Failed, 1)
      DataUploadImportJob.perform(1)
    end

    should 'do not send any email if not finished and failed' do
      @stub = mock(queued?: false, succeeded?: false, partially_succeeded?: false, failed?: false)
      DataUpload.stubs(:find).returns(@stub)
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Finished, 1).never
      WorkflowStepJob.expects(:perform).with(WorkflowStep::DataUploadWorkflow::Failed, 1).never
      DataUploadImportJob.perform(1)
    end

  end

  context 'with sync mode false' do
    setup do
      @transactable_type = stub()
      @stub = stub( xml_file: stub(proper_file_path: '/some/path'),
                   id: 1,
                   importable: @transactable_type,
                   :parsing_result_log => 'hello',
                   :parsing_result_log= => 'hello',
                   :parse_summary= => { new: { company: 1 }, updated: { company: 2 } },
                   :save! => true,
                   :queued? => true,
                   :import! => true,
                   failure: true,
                   sync_mode: false,
                   succeeded?: true,
                   touch: true
                  )
      DataUpload.stubs(:find).returns(@stub)

      @synchronizer = stub()
      DataImporter::NullSynchronizer.expects(:new).returns(@synchronizer)
      @validation_errors_tracker = stub(to_s: 'hello')
      DataImporter::Tracker::ValidationErrors.expects(:new).returns(@validation_errors_tracker)
      @summary_tracker = stub(new_entities: {company: 1}, updated_entities: {company: 2}, deleted_entities: {company: 3})
      DataImporter::Tracker::Summary.expects(:new).returns(@summary_tracker)
      @progress_tracker = stub()
      DataImporter::Tracker::ProgressTracker.expects(:new).returns(@progress_tracker)
      @trackers = [@validation_errors_tracker, @summary_tracker, @progress_tracker]
      @xml_file_stub = stub()
      @counter_stub = stub(all_objects_count: 100)
      DataImporter::XmlEntityCounter.stubs(:new).returns(@counter_stub)
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

