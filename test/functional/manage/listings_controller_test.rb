require 'test_helper'

class Manage::ListingsControllerTest < ActionController::TestCase

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company, :creator => @user)
    @location = FactoryGirl.create(:location, :company => @company)
    @location2 = FactoryGirl.create(:location, :company => @company)
    @listing_type = "Shared Office"
    FactoryGirl.create(:transactable_type_listing)
  end

  context "#create" do
    setup do
      @attributes = FactoryGirl.attributes_for(:transactable).reverse_merge!({:photos_attributes => [FactoryGirl.attributes_for(:photo)], :listing_type => @listing_type, :daily_price => 10 })
      @attributes.delete(:photo_not_required)
    end

    should 'log' do
      @tracker.expects(:created_a_listing).with do |listing, custom_options|
        listing == assigns(:listing) && custom_options == { via: 'dashboard' }
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == @user
      end

      post :create, {
        :listing => @attributes,
        :location_id => @location2.id
      }
    end

    should "create listing" do
      assert_difference('@location2.listings.count') do
        post :create, {
          :listing => @attributes,
          :location_id => @location2.id
        }
      end
      assert_redirected_to manage_locations_path
    end
  end

  context "with listing" do

    setup do
      @listing = FactoryGirl.create(:transactable, :location => @location, :photos_count_to_be_created => 1, :quantity => 2)
    end

    context 'CRUD' do
      setup do
        stub_mixpanel
        @related_instance = FactoryGirl.create(:instance)
        PlatformContext.current = PlatformContext.new(@related_instance)
        FactoryGirl.create(:transactable_type_listing)

        @related_company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id, instance: @related_instance)
        @related_location = FactoryGirl.create(:location_in_auckland, company: @related_company)
        @related_listing = FactoryGirl.create(:transactable, location: @related_location)
      end

      context "#edit" do
        should 'allow show edit form for related listing' do
          get :edit, :id => @related_listing.id, :location_id => @related_location.id
          assert_response :success
        end

        should 'not allow show edit form for unrelated listing' do
          assert_raises(Transactable::NotFound) { get :edit, :id => @listing.id, :location_id => @location.id }
        end
      end

      context "#update" do
        should 'allow update for related listing' do
          put :update, :id => @related_listing.id, :listing => { :name => 'new name', :daily_price => 10 }
          @related_listing.reload
          assert_equal 'new name', @related_listing.name
          assert_redirected_to manage_locations_path
        end
      end

      context "#destroy" do
        should 'allow destroy for related listing' do
          @tracker.expects(:deleted_a_listing).with do |listing, custom_options|
            listing == assigns(:listing)
          end
          assert_difference 'Transactable.count', -1 do
            delete :destroy, :id => @related_listing.id
          end
          assert_redirected_to manage_locations_path
        end

        should 'not allow destroy for unrelated listing' do
          assert_no_difference('Transactable.count') do
            assert_raises(Transactable::NotFound) { delete :destroy, :id => @listing.id }
          end
        end
      end
    end

    should "update listing" do
      put :update, :id => @listing.id, :listing => { :name => 'new name', :daily_price => 10}
      @listing.reload
      assert_equal 'new name', @listing.name
      assert_redirected_to manage_locations_path
    end

    should "update disable prices that are not checked" do
      @listing.daily_price = 10
      @listing.weekly_price = 20
      @listing.monthly_price = 30
      @listing.hourly_price = 1
      @listing.save!
      put :update, :id => @listing.id, :listing => { :weekly_price => 30.12 }
      @listing.reload
      assert_nil @listing.daily_price
      assert_nil @listing.monthly_price
      assert_nil @listing.hourly_price
      assert_equal 30.12, @listing.weekly_price
      assert_redirected_to manage_locations_path
    end

    should "destroy listing" do
      stub_mixpanel
      @tracker.expects(:updated_profile_information).with do |user|
        user == @user
      end
      assert_difference('@user.listings.count', -1) do
        delete :destroy, :id => @listing.id
      end

      assert_redirected_to manage_locations_path
    end

    should "track event from email" do
      stub_mixpanel
      @tracker.expects(:link_within_email_clicked).with do |user, custom_options|
        user == @user &&
        custom_options[:url] == '/manage/locations/:location_id/listings/:id/edit' &&
        custom_options[:mailer] == 'recurring_mailer/request_photos'
      end

      verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)

      get :edit, :id => @listing.id, :location_id => @location.id, :track_email_event => true, :email_signature => verifier.generate('recurring_mailer/request_photos')
    end

    context 'with reservation' do
      setup do
        stub_mixpanel
        @reservation1 = FactoryGirl.create(:reservation, :listing => @listing)
        @reservation2 = FactoryGirl.create(:reservation, :listing => @listing)
      end

      should 'notify guest about reservation expiration when listing is deleted' do
        ReservationMailer.expects(:notify_guest_of_expiration).returns(stub(deliver: true)).twice
        ReservationMailer.expects(:notify_host_of_expiration).returns(stub(deliver: true)).twice
        delete :destroy, :id => @listing.id
      end

      should 'mark reservations as expired' do
        ReservationMailer.stubs(:notify_guest_of_expiration).returns(stub(deliver: true))
        ReservationMailer.stubs(:notify_host_of_expiration).returns(stub(deliver: true))

        delete :destroy, :id => @listing.id
        assert_equal 'expired', @reservation1.reload.state
        assert_equal 'expired', @reservation2.reload.state
      end
    end

    context "someone else tries to manage our listing" do

      setup do
        @other_user = FactoryGirl.create(:user)
        @other_company = FactoryGirl.create(:company, :creator => @other_user)
        @other_locaiton = FactoryGirl.create(:location, :company => @company)
        sign_in @other_user
      end

      should "not create listing" do
        assert_raise Location::NotFound do
          post :create, { :listing => FactoryGirl.attributes_for(:transactable).reverse_merge!({:listing_type => @listing_type}), :location_id => @location.id}
        end
      end

      should 'handle lack of permission to edit properly' do
        assert_raise Transactable::NotFound do
          get :edit, :id => @listing.id
        end
      end

      should "not update listing" do
        assert_raise Transactable::NotFound do
          put :update, :id => @listing.id, :listing => { :name => 'new name' }
        end
      end

      should "not destroy listing" do
        assert_raise Transactable::NotFound do
          delete :destroy, :id => @listing.id
        end
      end
    end
  end

  context 'versions' do

    should 'track version change on create' do
      @attributes = FactoryGirl.attributes_for(:transactable).reverse_merge!({:photos_attributes => [FactoryGirl.attributes_for(:photo)], :listing_type => @listing_type, :daily_price => 10 })
      @attributes.delete(:photo_not_required)
      stub_mixpanel
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Transactable", "create").count') do
        with_versioning do
          post :create, { :listing => @attributes, :location_id => @location2.id }
        end
      end

    end

    should 'track version change on update' do
      @listing = FactoryGirl.create(:transactable, :location => @location, :quantity => 2)
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Transactable", "update").count') do
        with_versioning do
          put :update, :id => @listing.id, :listing => { :name => 'new name', :daily_price => 10 }
        end
      end
    end

    should 'track version change on destroy' do
      stub_mixpanel
      @listing = FactoryGirl.create(:transactable, :location => @location, :quantity => 2)
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Transactable", "destroy").count') do
        with_versioning do
          delete :destroy, :id => @listing.id
        end
      end
    end
  end


end
