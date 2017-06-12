# frozen_string_literal: true
require 'test_helper'
Dir[File.dirname(__FILE__) + '/builder_tests/*.rb'].each {|file| require file }

class MarketplaceBuilder::BuilderTest < ActiveSupport::TestCase
  EXAMPLE_MARKETPLACE_PATH = "#{Rails.root}/test/unit/interactors/marketplace_builder/example_marketplace"

  context 'marketplace builder' do
    should 'import all files from example_marketplace dir' do
      stub_request(:get, 'https://example_url.jpg').to_return(status: 200)
      @instance = create(:instance)
      @instance.set_context!
      Locale.create! code: 'en', instance_id: @instance.id
      NewMarketplaceBuilder::Interactors::ImportInteractor.new(@instance.id, EXAMPLE_MARKETPLACE_PATH).execute!

      builder_test_classes = MarketplaceBuilder::BuilderTests.constants.select do |klass|
        MarketplaceBuilder::BuilderTests.const_get(klass).is_a? Class
      end

      builder_test_classes.each do |test_class|
        instance_of_test_class = "MarketplaceBuilder::BuilderTests::#{test_class.to_s}".constantize.new @instance
        instance_of_test_class.instance_variable_set(:@assertions, @assertions)
        instance_of_test_class.execute!
        @assertions = instance_of_test_class.instance_variable_get(:@assertions)
      end
    end

    should 'skip importing if md5 is not changed' do
      @instance = create(:instance)
      @instance.set_context!
      Locale.create! code: 'en', instance_id: @instance.id

      NewMarketplaceBuilder::Interactors::ImportInteractor.new(@instance.id, EXAMPLE_MARKETPLACE_PATH).execute!
      instance_view = InstanceView.last
      after_first_import_timestamp = instance_view.updated_at

      sleep 2
      NewMarketplaceBuilder::Interactors::ImportInteractor.new(@instance.id, EXAMPLE_MARKETPLACE_PATH).execute!
      instance_view.reload
      after_second_import_timestamp = instance_view.updated_at

      assert_equal after_first_import_timestamp.to_i, after_second_import_timestamp.to_i
    end

    should 'remove deleted models' do
      begin
        @instance = create(:instance)
        @instance.set_context!
        Locale.create! code: 'en', instance_id: @instance.id

        NewMarketplaceBuilder::Interactors::ImportInteractor.new(@instance.id, EXAMPLE_MARKETPLACE_PATH).execute!
        FileUtils.mv("#{EXAMPLE_MARKETPLACE_PATH}/liquid_views/home/index.liquid", 'tmp/index.liquid.mbuilder')

        NewMarketplaceBuilder::Interactors::ImportInteractor.new(@instance.id, EXAMPLE_MARKETPLACE_PATH).execute!

        assert_equal 0, InstanceView.where(view_type: 'view').count
      ensure
        FileUtils.mv('tmp/index.liquid.mbuilder', "#{EXAMPLE_MARKETPLACE_PATH}/liquid_views/home/index.liquid")
      end
    end
  end
end
