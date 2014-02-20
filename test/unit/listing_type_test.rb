require 'test_helper'

class ListingTypeTest < ActiveSupport::TestCase

  should have_many(:listings)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).scoped_to(:instance_id)

  context 'metadata' do

      setup do
        @listing_type = FactoryGirl.create(:listing_type)
      end

      should 'not trigger populate metadata if name has not changed' do
        @listing_type.expects(:populate_listings_metadata!).never
        @listing_type.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
      end

      should 'trigger populate metadata if name changed' do
        @listing_type.expects(:populate_listings_metadata!).once
        @listing_type.update_attribute(:name, 'new cool name')
      end

      should 'trigger the right method of listing if metadata changed' do
        @listing_stub = stub()
        @listing_stub.expects(:populate_listing_type_name_metadata!)
        @listing_type.expects(:listings).returns(stub(:reload => [@listing_stub]))
        @listing_type.populate_listings_metadata!
      end
  end

end
