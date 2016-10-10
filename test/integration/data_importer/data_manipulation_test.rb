require 'test_helper'

class DataImporter::DataManipulationTest < ActiveSupport::TestCase
  should 'should be able to parse CSV without external ids' do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @user = FactoryGirl.create(:admin)
    @transactable_type = FactoryGirl.create(:transactable_type_current_data)

    assert_nothing_raised do
      @data_upload = FactoryGirl.create(:data_upload,
                                        importable: @transactable_type,
                                        csv_file: File.open(Rails.root.join('test', 'assets', 'data_importer', 'mpo_current_data_without_external_ids.csv')),
                                        target: @instance,
                                        uploader: @user
                                       )
      DataUploadConvertJob.perform(@data_upload.id)
      assert @data_upload.reload.encountered_error.blank?
    end
  end
end
