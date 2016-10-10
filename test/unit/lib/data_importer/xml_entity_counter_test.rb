require 'test_helper'

class DataImporter::XmlEntityCounterTest < ActiveSupport::TestCase
  def setup
    @xml_entity_counter = DataImporter::XmlEntityCounter.new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file.xml'))
  end

  should 'return all objects count' do
    assert_equal 12, @xml_entity_counter.all_objects_count
  end
end
