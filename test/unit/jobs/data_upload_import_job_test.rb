require 'test_helper'

class DataUploadImportJobTest < ActiveSupport::TestCase

  setup do
    @stub = stub(
      xml_file: stub(proper_file_path: '/some/path'),
      transactable_type: stub(),
      :parsing_result_log= => 'result',
      :parse_summary= => { :result => {} },
      :save! => true
    )
    DataUpload.stubs(:find).returns(@stub)
    @xml_file_stub = stub(get_parse_result: 'result', get_summary: { :result => {} })
    DataImporter::XmlFile.stubs(:new).returns(@xml_file_stub)
  end
  should 'store exception which has been raised' do
    @xml_file_stub.stubs(:parse).raises(StandardError.new('*Custom exception*'))
    @stub.expects(:encountered_error=).with do |error_string|
      error_string.include?('*Custom exception*') && error_string.include?('app/jobs/data_upload_import_job.rb:')
    end
    DataUploadImportJob.perform(1)
  end

end

