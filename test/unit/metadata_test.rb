require 'test_helper'

class MetadataTest < ActiveSupport::TestCase


  setup do
    @dummy_class = Listing.new
  end

  should 'respond to metadata' do
    assert @dummy_class.respond_to?(:metadata)
  end

  should 'trigger update_column with right arguments' do
    @dummy_class.expects(:update_column).with(:metadata, {:a => 'b'}.to_json)
    @dummy_class.update_metadata({:a => 'b'})
  end

  should 'not overwrite existing keys' do
    @dummy_class.metadata = { :a => 'b' }
    @dummy_class.expects(:update_column).with(:metadata, {:a => 'b', :b => 'c'}.to_json)
    @dummy_class.update_metadata({:b => 'c'})
  end

  should 'raise an error if wrong argument is passed' do
    assert_raise Metadata::InvalidArgumentError do
      @dummy_class.update_metadata([])
    end
  end

  should 'add syntax sugar to access metadata' do
    @dummy_class.metadata = { 'some_key' => 'key_value' }
    assert_equal 'key_value', @dummy_class.some_key_metadata
  end


end
