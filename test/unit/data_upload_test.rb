require 'test_helper'

class DataUploadTest < ActiveSupport::TestCase

  context "#num_rows" do
    should "return num rows in csv file not counting headers" do
      data_upload = DataUpload.new(csv_file: File.open('test/assets/data_importer/products/current_data.csv'))
      assert_equal 2, data_upload.num_rows
    end

    should "raise error if there is no csv file" do
      assert_raise IOError do
        DataUpload.new.num_rows
      end
    end
  end

end
