require 'test_helper'

class SpreeDefaultsLoaderTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.first
    Currency.destroy_all
    Country.destroy_all
    @loader = Utils::SpreeDefaultsLoader.new(@instance)
  end

  context '#load!' do
    setup do
      @loader.load!
    end

    should 'find Spree::Store record' do
      store = Spree::Store.find_by(name: @instance.theme.site_name)

      assert_not_nil store
      assert_equal store.url, @instance.domains.first.name
      assert_equal store.meta_keywords, @instance.theme.tagline
      assert_equal store.seo_title, @instance.theme.meta_title
    end

    should 'set preferences' do
      check_default_preferences
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

  context 'load multiple instances' do
    setup do
      @test_instance = create(:instance, name: 'Test instance')
      @test_instance.domains << @domain = FactoryGirl.create(:domain)
      PlatformContext.current = PlatformContext.new(@test_instance)
      Utils::SpreeDefaultsLoader.new(@test_instance).load!
    end

    should 'find Spree::Store record' do
      store = Spree::Store.find_by(name: @test_instance.theme.site_name)

      assert_not_nil store
      assert_equal store.url, @test_instance.domains.first.name
      assert_equal store.meta_keywords, @test_instance.theme.tagline
      assert_equal store.seo_title, @test_instance.theme.meta_title
    end

    should 'set preferences' do
      check_default_preferences
    end

    should 'mantain preferences for other instances after preference change' do
      PlatformContext.current = PlatformContext.new(@test_instance)

      # Spree::Config.allow_ssl_in_staging = true
      Spree::Config.currency = 'PLN'

      PlatformContext.current = PlatformContext.new(@instance)
      check_default_preferences

      PlatformContext.current = PlatformContext.new(@test_instance)
      # assert_equal Spree::Config.allow_ssl_in_staging, true
      assert_equal Spree::Config.currency, 'PLN'
    end

  end

  def check_default_preferences
    # assert_equal Spree::Config.allow_ssl_in_staging, false
    assert_equal Spree::Config.currency, 'USD'
  end
end
