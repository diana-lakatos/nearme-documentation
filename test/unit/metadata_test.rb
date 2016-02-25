require 'test_helper'

class MetadataTest < ActiveSupport::TestCase


  setup do
    @dummy_class = Company.new
  end

  should 'respond to metadata' do
    assert @dummy_class.respond_to?(:metadata)
  end

  should 'trigger update_column with right arguments for update_metadata' do
    @dummy_class.update_metadata({:a => 'b'})
    assert @dummy_class.metadata, {:a => 'b'}
  end

  should 'trigger update_column with right arguments for update_instance_metadata' do

    @dummy_class.expects(:update_columns).with do |arr|
      arr[:metadata].with_indifferent_access == { PlatformContext.current.instance.id.to_s => {:a => 'b'} }.with_indifferent_access
    end
    @dummy_class.update_instance_metadata({:a => 'b'})
  end

  should 'not overwrite existing keys' do
    @dummy_class.metadata = { :a => 'b' }
    assert @dummy_class.metadata, {:a => 'b', :b => 'c'}
  end

  should 'raise an error if wrong argument is passed' do
    assert_raise Metadata::Base::InvalidArgumentError do
      @dummy_class.update_metadata([])
    end
  end

end
