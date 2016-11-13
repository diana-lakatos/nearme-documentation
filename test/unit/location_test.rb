# frozen_string_literal: true
require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  subject do
    @location = FactoryGirl.create(:location)
  end

  should belong_to(:company)
  should belong_to(:administrator)
  should belong_to(:location_type)
  should have_many(:listings)

  should validate_presence_of(:company)
  should_not allow_value('not_an_email').for(:email)
  should allow_value('an_email@domain.com').for(:email)

  should 'be valid even if its listing is not valid' do
    @location = FactoryGirl.create(:location)
    @listing = FactoryGirl.create(:transactable, location: @location)
    @listing.name = nil
    @listing.save(validate: false)
    @location.reload
    assert @location.valid?
  end

  context '#name' do
    setup do
      @location = FactoryGirl.create(:location_in_san_francisco)
      @location.company.update_attribute(:name, 'This is company name')
    end

    should 'use combination of company name and street if available' do
      @location.location_address.street = 'My Street'
      assert_equal 'This is company name @ My Street', @location.name
    end

    should 'use combination of company name and part of address if available' do
      @location.location_address.attributes = { street: nil, address: 'Your Street, City, Country' }
      assert_equal 'This is company name @ Your Street', @location.name
    end
  end

  context '#description' do
    context 'when not set' do
      context 'and there is not a listing for the location' do
        should 'return an empty string' do
          location = Location.new
          assert_equal '', location.description
        end
      end

      context 'and there is a listing with a description' do
        should 'return the first listings description' do
          location = Location.new
          location.listings << FactoryGirl.build(:transactable, description: 'listing description', location: location)
          assert_equal 'listing description', location.description
        end
      end
    end
  end

  context 'availability' do
    should "return an Availability::Summary for the Location's availability rules" do
      location = Location.new
      location.availability_template = AvailabilityTemplate.new(availability_rules: [AvailabilityRule.new(days: [0], open_hour: 6, open_minute: 0, close_hour: 20, close_minute: 0)])
      assert location.availability.is_a?(AvailabilityRule::Summary)
      assert location.availability.open_on?(day: 0, hour: 6)
      assert !location.availability.open_on?(day: 1)
    end

    should 'return an Array of full week availability ordered by day' do
      location = Location.new
      location.availability_template =
        AvailabilityTemplate.new(
          availability_rules: [
            AvailabilityRule.new(days: [0, 2], open_hour: 6, open_minute: 0, close_hour: 20, close_minute: 0)
          ]
        )
      availability_all = location.availability.full_week
      assert availability_all.is_a?(Array)
      assert_equal 7, availability_all.count
      assert_equal 1, availability_all[0][:day]
      assert_equal 2, availability_all[1][:day]
      assert_equal [nil], availability_all[1][:rules].map(&:id)
    end
  end

  context 'url slugging' do
    setup do
      @company = FactoryGirl.create(:company, name: 'Desks Near Me')
    end

    should 'store slug in the database' do
      @location = FactoryGirl.build(:location_in_san_francisco, company: @company)
      @location.stubs(:formatted_address).returns('San Francisco, CA, California, USA')
      @location.stubs(:city).returns('San Francisco')
      @location.save!
      assert_equal 'desks-near-me-san-francisco', @location.slug
    end

    should 'ignore city name if company name already includes it ' do
      @company.update_attribute(:name, 'Paradise of San Francisco')
      @location = FactoryGirl.build(:location_in_san_francisco, company: @company)
      @location.stubs(:formatted_address).returns('San Francisco, CA, California, USA')
      @location.stubs(:city).returns('San Francisco')
      @location.save!
      assert_equal 'paradise-of-san-francisco', @location.slug
    end

    should 'keep the same slug on save if company_and_city did not change' do
      @location = FactoryGirl.build(:location_in_san_francisco, company: @company)
      @location.stubs(:formatted_address).returns('San Francisco, CA, California, USA')
      @location.stubs(:city).returns('San Francisco')
      @location.save!
      original_slug = @location.slug
      @location.save!
      assert @location.slug == original_slug
    end

    should 'generate a new slug on save if the company_and_city  changed' do
      @location = FactoryGirl.build(:location_in_san_francisco, company: @company)
      @location.stubs(:formatted_address).returns('San Francisco, CA, California, USA')
      @location.stubs(:city).returns('San Francisco')
      @location.save!
      assert_equal 'desks-near-me-san-francisco', @location.slug
      @location.stubs(:city).returns('Los Angeles')
      @location.save!
      assert_equal 'desks-near-me-los-angeles', @location.slug
    end
  end

  context 'metadata' do
    context 'populating hash' do
      setup do
        @location = FactoryGirl.create(:transactable, photos_count: 1).location
        @photo = @location.photos.first
      end

      should 'initialize metadata' do
        @location.expects(:update_metadata).with(photos_metadata: [{
                                                   original: @photo.image.url,
                                                   space_listing: @photo.image_url(:space_listing),
                                                   golden: @photo.image_url(:golden),
                                                   large: @photo.image_url(:large),
                                                   listing_name: @photo.listing.name,
                                                   caption: @photo.caption
                                                 }])
        @location.populate_photos_metadata!
      end

      context 'with second image' do
        setup do
          @photo2 = FactoryGirl.create(:photo, owner: @location.listings.first, creator: @location.creator)
        end

        should 'update existing metadata' do
          # need to find it another time because versions generated by job and don't exist in @photo2 yet
          photo2 = Photo.find(@photo2.id)

          @location.expects(:update_metadata).with(photos_metadata: [
                                                     {
                                                       original: @photo.image.url,
                                                       space_listing:  @photo.image_url(:space_listing),
                                                       golden:  @photo.image_url(:golden),
                                                       large:  @photo.image_url(:large),
                                                       listing_name:  @photo.listing.name,
                                                       caption:  @photo.caption
                                                     },
                                                     {
                                                       original:  photo2.image.url,
                                                       space_listing:  photo2.image_url(:space_listing),
                                                       golden:  photo2.image_url(:golden),
                                                       large:  photo2.image_url(:large),
                                                       listing_name:  photo2.listing.name,
                                                       caption:  photo2.caption
                                                     }
                                                   ])
          @location.populate_photos_metadata!
        end
      end
    end
  end

  context 'foreign keys' do
    setup do
      @company = FactoryGirl.create(:company)
      @location = FactoryGirl.create(:location, company: @company)
    end

    should 'assign correct key immediately' do
      @location = FactoryGirl.create(:location)
      assert @location.creator_id.present?
      assert @location.company_id.present?
      assert @location.instance_id.present?
    end

    should 'assign correct creator_id' do
      assert_equal @company.creator_id, @location.creator_id
    end

    should 'assign correct company_id' do
      assert_equal @company.id, @location.company_id
    end
  end

  should 'populate external id' do
    @location = FactoryGirl.create(:location)
    assert_not_nil @location.reload.external_id
  end

  context 'timezone' do
    should 'update related transactables schedules when timezone changesxxx' do
      location = FactoryGirl.create(:location)
      @listing = FactoryGirl.create(:transactable, :fixed_price, location: location)
      first_occurence_in_utc = @listing.event_booking.schedule.schedule.next_occurrences(1)
      location.reload
      location.time_zone = 'Pacific Time (US & Canada)'
      assert location.save
      first_occurence_in_pst = @listing.reload.event_booking.schedule.schedule.next_occurrences(1)
      refute first_occurence_in_pst[0].to_s == first_occurence_in_utc[0].to_s
    end
  end
end
