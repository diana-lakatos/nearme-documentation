require 'test_helper'

class DataImporter::FileTest < ActiveSupport::TestCase

  context '#initializize' do

    should 'take path to the file as argument' do
      DataImporter::File.new(get_absolute_file_path('data.csv'))
    end

    should 'raise error if file is not found' do
      assert_raise RuntimeError do
        DataImporter::File.new(get_absolute_file_path('/not/exists'))
      end
    end

  end

  private

  def get_absolute_file_path(name)
    Rails.root.join('test', 'assets', 'data_importer') + name
  end
end
