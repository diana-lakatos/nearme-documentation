require 'test_helper'

class DataUploadHostConvertJobTest < ActiveSupport::TestCase

  setup do
    @stub = stub(:save! => true, :process! => true, fail: true, id: 10)
    DataUpload.stubs(:find).returns(@stub)
    DataUploadImportJob.expects(:perform).with(10)
  end
  should 'store exception which has been raised' do
    DataImporter::Host::CsvFile::TemplateCsvFile.stubs(:new).raises(StandardError.new('*Custom exception*'))
    @stub.expects(:encountered_error=).with do |error_string|
      error_string.include?('*Custom exception*') && error_string.include?('app/jobs/data_upload_host_convert_job.rb:')
    end
    DataUploadHostConvertJob.perform(1)
  end
end
