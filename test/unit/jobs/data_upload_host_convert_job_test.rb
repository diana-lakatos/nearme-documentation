require 'test_helper'

class DataUploadHostConvertJobTest < ActiveSupport::TestCase
  setup do
    FactoryGirl.create(:data_upload)
  end
  should 'store exception which has been raised' do
    DataImporter::Host::CsvFile::TemplateCsvFile.stubs(:new).raises(StandardError.new('*Custom exception*'))
    DataUpload.any_instance.expects(:encountered_error=).with do |error_string|
      error_string.include?('*Custom exception*') && error_string.include?('app/jobs/data_upload_host_convert_job.rb:')
    end
    DataUploadHostConvertJob.perform(DataUpload.first.id)
  end
end
