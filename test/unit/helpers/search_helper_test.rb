require 'test_helper'

class SearchHelperTest < ActionView::TestCase

  include MoneyRails::ActionViewExtension

  context 'listing' do
    setup do
      @listing = FactoryGirl.create(:listing_with_10_dollars_per_hour)
      @location = @listing.location
    end

    should "#listing_price_information" do
      assert_equal "$10 <span>/ hour</span>", listing_price_information(@listing)
      assert_equal "$50 <span>/ day</span>", listing_price_information(@listing, ['daily'])
    end

    should "#location_price_information" do
      assert_equal "From <span>$10</span> / hour", location_price_information(@location)
      assert_equal "From <span>$50</span> / day", location_price_information(@location, ['daily'])
    end
  end

  context 'product' do
    setup do
      @taxonomy = FactoryGirl.create(:taxonomy, name: 'Brand')
      @taxons = (0..1).map do |i|
        FactoryGirl.create(:taxon, taxonomy: @taxonomy, name: "RoR #{i}", parent: @taxonomy.root)
      end
    end

    should "#display_taxonomies" do
      assert display_taxonomies(@taxonomy.root).include?(@taxons.first.name)
      assert display_taxonomies(@taxonomy.root).include?(@taxons.second.name)
      assert display_taxonomies(@taxonomy.root, @taxons.first).include?('current')
    end
  end
end
