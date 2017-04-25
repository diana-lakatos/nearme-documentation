# frozen_string_literal: true
require 'test_helper'
Dir[File.dirname(__FILE__) + '/exporter_tests/*.rb'].each {|file| require file }

class MarketplaceBuilder::ExporterTest < ActiveSupport::TestCase
  EXPORT_DESTINATION_PATH = "#{Rails.root}/tmp/exported_instances"

  context 'marketplace exporter' do
    should 'export instance to files' do
      stub_request(:get, 'http://example.com/test.jpg').to_return(status: 200)
      @instance = create(:instance, name: 'ExportTestInstance', is_community: true, require_verified_user: false)
      @instance.set_context!
      Locale.create! code: 'en'

      exporter_test_classes = MarketplaceBuilder::ExporterTests.constants.select do |klass|
        MarketplaceBuilder::ExporterTests.const_get(klass).is_a? Class
      end.map do |test_class_sym|
        "MarketplaceBuilder::ExporterTests::#{test_class_sym.to_s}".constantize.new @instance
      end

      exporter_test_classes.each do |test_class|
        test_class.seed!
      end

      NewMarketplaceBuilder::Interactors::ExportInteractor.new(@instance.id, EXPORT_DESTINATION_PATH).execute!

      exporter_test_classes.each do |test_class|
        test_class.instance_variable_set(:@assertions, @assertions)
        test_class.execute!
        @assertions = test_class.instance_variable_get(:@assertions)
      end

      FileUtils.rm_rf(EXPORT_DESTINATION_PATH)
    end
  end
end
