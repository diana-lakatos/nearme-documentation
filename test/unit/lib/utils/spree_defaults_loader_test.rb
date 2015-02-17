require 'test_helper'

class SpreeDefaultsLoaderTest < ActiveSupport::TestCase

  setup do
    @loader = Utils::SpreeDefaultsLoader.new(Instance.first)
  end

  context '#load!' do
    setup do
      @loader.load!
    end

    should 'find Spree::Store record' do
      store = Spree::Store.find_by(name: 'Desks Near Me')
      instance = Instance.first
      assert_not_nil store
      assert_equal store.name, instance.theme.site_name
      assert_equal store.url, instance.domains.first.name
      assert_equal store.meta_keywords, instance.theme.tagline
      assert_equal store.seo_title, instance.theme.meta_title
    end

    should 'set preferences' do
      assert_equal Spree::Config.display_currency, false
      assert_equal Spree::Config.allow_ssl_in_staging, false
      assert_equal Spree::Config.currency, 'USD'
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
