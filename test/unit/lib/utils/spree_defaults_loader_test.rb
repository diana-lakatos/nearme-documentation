require 'test_helper'

class SpreeDefaultsLoaderTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    @domain = FactoryGirl.create(:domain, name: 'example.com', target: @instance)
    @loader = Utils::SpreeDefaultsLoader.new(@instance)
  end

  context '#load!' do
    setup do
      PlatformContext.current = PlatformContext.new(@instance)
      @loader.load!
    end

    should 'set preferences' do
      assert_equal Spree::Config.site_name, 'Desks Near Me'
      assert_equal Spree::Config.site_url, 'example.com'
      assert_equal Spree::Config.default_meta_keywords, 'Find a space to work'
      assert_equal Spree::Config.default_seo_title, 'Desks Near Me'
      assert_equal Spree::Config.display_currency, false
      assert_equal Spree::Config.allow_ssl_in_staging, false
      assert_equal Spree::Config.currency, 'USD'
      assert_equal Spree::Config.shipment_inc_vat, true
      assert_equal Spree::Config.override_actionmailer_config, false
    end

    should 'load countries' do
      assert_not_equal Spree::Country.count, 0
    end

    should 'load roles' do
      assert_equal Spree::Role.count, 2
      assert_equal Spree::Role.pluck(:name).sort, ['admin', 'user']
    end

    should 'load zones' do
      assert_equal Spree::Zone.count, 2
    end

    should 'load tax categories and rates' do
      assert_equal Spree::TaxCategory.count, 1
      assert_equal Spree::TaxCategory.first.tax_rates.count, 2
    end

    should 'load shipping methods' do
      assert_equal Spree::ShippingCategory.count, 1
      assert_equal Spree::ShippingCategory.first.shipping_methods.count, 1
    end
  end
end
