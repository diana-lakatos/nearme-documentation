# frozen_string_literal: true
require 'test_helper'

class TransactableTest < ActiveSupport::TestCase
  context 'desksnearme instance' do
    subject { FactoryGirl.build(:transactable, :desksnearme) }

    should belong_to(:location)
    should have_many(:reservations)
    should have_many(:orders)
    should have_many(:transactable_collaborators)
    should have_many(:transactable_topics)
    should have_many(:topics)
    should have_many(:user_messages)
    should have_many(:wish_list_items)
    should have_many(:photos)
    should have_many(:links)

    should belong_to(:transactable_type)
    should belong_to(:creator)

    should validate_presence_of(:location)
    should validate_presence_of(:name)
    should validate_presence_of(:description)
    should validate_presence_of(:quantity)
    should allow_value(10).for(:quantity)
    should_not allow_value(-10).for(:quantity)
  end

  setup do
    @listing = FactoryGirl.build(:transactable)
    @manual_payment_method = FactoryGirl.create(:manual_payment_gateway).payment_methods.first
  end

  context 'is trusted' do
    setup do
      @transactable = FactoryGirl.create(:transactable)
      @transactable.approval_requests = []
      @approval_request = FactoryGirl.build(:approval_request)
      @approval_request.owner = @transactable
      @approval_request.save!
    end

    context 'instance does not require verification' do
      should 'be trusted even without approved approval requests' do
        assert @transactable.is_trusted?
      end
    end

    context 'instance does require verification' do
      setup do
        FactoryGirl.create(:approval_request_template, owner_type: 'Transactable')
      end

      should 'not be trusted without approved approval request' do
        refute @transactable.is_trusted?
      end

      should 'be not trusted without approval request despite user is trusted' do
        User.any_instance.stubs(:is_trusted?).returns(true)
        refute @transactable.is_trusted?
      end

      should 'be trusted with approval request that is accepted' do
        @approval_request.accept!
        assert @transactable.reload.is_trusted?
      end

      context 'enabled' do
        setup do
          User.any_instance.stubs(:approval_requests).returns([@approval_request])
        end

        should 'be enabled if is trusted' do
          Transactable.any_instance.stubs(:is_trusted?).returns(true)
          assert FactoryGirl.create(:transactable).enabled?
        end

        should 'not be enabled if is not trusted' do
          Transactable.any_instance.stubs(:is_trusted?).returns(false)
          refute FactoryGirl.create(:transactable, enabled: true).enabled?
        end

        should 'not be enabled if trusted but opted to be disabled' do
          Transactable.any_instance.stubs(:is_trusted?).returns(true)
          refute FactoryGirl.create(:transactable, enabled: false).enabled?
        end
      end
    end
  end

  context '#photo_not_required' do
    should 'not require photo' do
      @listing.photo_not_required = true
      @listing.photos = []
      assert @listing.valid?
    end
  end

  context 'metadata' do
    context 'populating photo hash' do
      setup do
        @listing = FactoryGirl.create(:transactable, photos_count: 1)
        @photo = Photo.last
      end

      should 'initialize metadata' do
        @listing.expects(:update_metadata).with(photos_metadata: [{
                                                  listing_name: @photo.listing.name,
                                                  original: @photo.image.url,
                                                  space_listing: @photo.image_url(:space_listing),
                                                  golden: @photo.image_url(:golden),
                                                  large: @photo.image_url(:large),
                                                  caption: @photo.caption
                                                }])
        @listing.populate_photos_metadata!
      end

      should 'trigger location metadata' do
        Location.any_instance.expects(:populate_photos_metadata!).once
        @listing.populate_photos_metadata!
      end

      context 'with second image' do
        setup do
          @photo2 = FactoryGirl.create(:photo, owner: @listing, creator: @listing.creator)
          # need to find it another time because versions generated by job and don't exist in @photo2 yet
          @photo2 = Photo.last
        end

        should 'update existing metadata' do
          @listing.expects(:update_metadata).with(photos_metadata: [
                                                    {
                                                      listing_name: @photo.listing.name,
                                                      original: @photo.image.url,
                                                      space_listing: @photo.image_url(:space_listing),
                                                      golden: @photo.image_url(:golden),
                                                      large: @photo.image_url(:large),
                                                      caption: @photo.caption
                                                    },
                                                    {
                                                      listing_name: @photo2.listing.name,
                                                      original: @photo2.image.url,
                                                      space_listing: @photo2.image_url(:space_listing),
                                                      golden: @photo2.image_url(:golden),
                                                      large: @photo2.image_url(:large),
                                                      caption: @photo2.caption
                                                    }
                                                  ])
          @listing.populate_photos_metadata!
        end
      end
    end
  end

  context 'foreign keys' do
    setup do
      @location = FactoryGirl.create(:location)
      @listing = FactoryGirl.create(:transactable, location: @location)
    end

    should 'assign correct key immediately' do
      @listing = FactoryGirl.create(:transactable)
      assert @listing.creator_id.present?
      assert @listing.instance_id.present?
      assert @listing.company_id.present?
      assert @listing.listings_public
    end

    should 'assign correct creator_id' do
      assert_equal @location.creator_id, @listing.creator_id
    end

    should 'assign correct company_id' do
      assert_equal @location.company_id, @listing.company_id
    end

    should 'assign administrator_id' do
      @location.update_attribute(:administrator_id, @location.creator_id + 1)
      assert_equal @location.administrator_id, @listing.reload.administrator_id
    end
  end

  should 'populate external id' do
    @transactable = FactoryGirl.create(:transactable)
    assert_not_nil @transactable.reload.external_id
  end

  context 'with reservations' do
    setup do
      @listing = FactoryGirl.build(:transactable, :with_time_based_booking)
    end

    should 'return monday for tuesday if the whole week is booked' do
      WorkflowStepJob.expects(:perform).with do |klass, _int|
        klass == WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation
      end

      # @action.save!
      tuesday = Time.zone.today.sunday + 2
      travel_to tuesday.beginning_of_day do
        dates = [tuesday]
        4.times do |i|
          dates << tuesday + i.day
        end
        res = @listing.reserve!(FactoryGirl.build(:user), dates, 1, @listing.action_type.day_pricings.first)
        res.confirm
        # wednesday, thursday, friday = 3, saturday, sunday = 2 -> monday is sixth day
        assert_equal tuesday + 6.days, @listing.action_type.first_available_date
      end
    end

    should 'return wednesday for tuesday if there is one desk left' do
      WorkflowStepJob.expects(:perform).twice.with do |klass, _int|
        klass == WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation
      end

      @listing.quantity = 2
      @listing.save!
      tuesday = Time.zone.today.sunday + 2
      travel_to tuesday.beginning_of_day do
        # book all seats on wednesday
        res = @listing.reserve!(FactoryGirl.build(:user), [tuesday], 2, @listing.action_type.day_pricings.first)
        res.confirm
        # leave one seat free on thursday
        res = @listing.reserve!(FactoryGirl.build(:user), [tuesday + 1.day], 1, @listing.action_type.day_pricings.first)
        res.confirm
        # the soonest day should be the one with at least one seat free
        assert_equal tuesday + 1.day, @listing.action_type.first_available_date
      end
    end

    should 'return wednesday for monday if hourly reservation and custom availability template' do
      @listing.action_type.hour_pricings.first.price_cents = 5000
      @listing.action_type.availability_template = AvailabilityTemplate.new(availability_rules_attributes: [{ days: [3], open_hour: 9, close_hour: 16, open_minute: 0, close_minute: 0 }])
      # @action.save!

      monday = Time.zone.today.sunday + 1
      travel_to monday.beginning_of_day do
        assert_equal monday + 2.days, @listing.action_type.first_available_date
      end
    end
  end

  context 'scopes' do
    setup do
      @transactable = FactoryGirl.create(:transactable)
    end

    should '.by_topic' do
      @topic1 = create(:topic)
      @topic2 = create(:topic)
      @transactable.topics << [@topic1, @topic2]
      @another_listing = FactoryGirl.create(:transactable)
      assert_includes Transactable.by_topic([@topic1.id, @topic2.id]), @transactable
    end
  end

  context 'associated links' do
    should 'update links when transactable is saved' do
      @transactable = FactoryGirl.create(:transactable)
      @transactable.links << FactoryGirl.create(:link)

      @link = @transactable.links.first

      links_attributes = { '0' => { 'text' => 'Changed', id: @link.id } }
      @transactable.update_attributes('links_attributes' => links_attributes)
      assert_equal 'Changed', @transactable.links[0].text
    end
  end

  context 'with event based bookings' do
    setup do
      @listing = FactoryGirl.create(:transactable, :fixed_price)
    end

    should 'clear transactable opened_on_days if moved to event based booking' do
      @listing.update_column(:opened_on_days, [0,1,2,3])
      @listing.reload
      assert_equal [0,1,2,3], @listing.opened_on_days

      @listing.save
      assert_equal [], @listing.opened_on_days
    end
  end
end
