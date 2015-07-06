require 'test_helper'

class DataImporter::CsvFileValidatorTest < ActiveSupport::TestCase
  context '#strip_invalid_rows witn fields to check' do
    setup do
      csv_path = Rails.root.join('test/fixtures/csv_file_validator_test.csv')
      @existing_csv = CSV.new(open(csv_path))
      @filtered_csv, @invalid_rows = DataImporter::CsvFileValidator.new(csv_path, 'Company External Id').strip_invalid_rows
    end

    should 'strip invalid rows' do
      assert_not_empty @invalid_rows
      assert_equal '1.', @invalid_rows[0][0..1]
    end

    should 'keep valid rows' do
      filtered_lines = @filtered_csv.readlines
      assert_equal 2, filtered_lines.size
      assert_equal @existing_csv.readlines[2], filtered_lines[1]
    end

    should 'keep headers' do
      assert_equal @existing_csv.readlines[0], @filtered_csv.readlines[0]
    end

    should 'return CSV object' do
      assert_kind_of CSV, @filtered_csv
      assert_equal 0, @filtered_csv.lineno
    end
  end
end
