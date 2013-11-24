require 'test_helper'

class Manage::LocationsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company, :creator => @user)
    @location_type = FactoryGirl.create(:location_type)
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:locations)
  end

  context "#create" do

    should "create location and log" do
      stub_mixpanel
      @tracker.expects(:created_a_location).with do |location, custom_options|
        location == assigns(:location) && custom_options == { via: 'dashboard' }
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == @user
      end
      assert_difference('@user.locations.count') do
        post :create, { :location => FactoryGirl.attributes_for(:location_in_auckland).reverse_merge!({:location_type_id => @location_type.id})}
      end
      assert_redirected_to manage_locations_path
    end
  end

  context "with location" do

    setup do
      @location = FactoryGirl.create(:location_in_auckland, :company => @company)
    end

    context 'CRUD' do
      setup do
        stub_mixpanel
        @related_instance = FactoryGirl.create(:instance)
        PlatformContext.any_instance.stubs(:instance).returns(@related_instance)

        @related_company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id, instance: @related_instance)
        @related_location = FactoryGirl.create(:location_in_auckland, company: @related_company)
        @related_listing = FactoryGirl.create(:listing, location: @related_location)
      end

      context '#edit' do
        should 'allow show edit form for related location' do
          get :edit, :id => @related_location.id
          assert_response :success
        end

        should 'not allow show edit form for unrelated location' do
          assert_raises(Location::NotFound) { get :edit, :id => @location.id }
        end
      end

      context '#update' do
        should 'allow update for related location' do
          put :update, :id => @related_location.id, :location => { :description => 'new description' }
          @related_location.reload
          assert_equal 'new description', @related_location.description
          assert_redirected_to manage_locations_path
        end

        should 'not allow update for unrelated location' do
          assert_raises(Location::NotFound) do
            put :update, :id => @location.id, :location => { :description => 'new description' }
          end
        end
      end

      context '#destroy' do
        should 'allow destroy for related location' do
          assert_difference('Location.count', -1) do
            delete :destroy, :id => @related_location.id
          end
          assert_redirected_to manage_locations_path
        end

        should 'not allow destroy for unrelated location' do
          assert_no_difference('Location.count') do
            assert_raises(Location::NotFound) { delete :destroy, :id => @location.id }
          end
        end
      end
    end

    should "update location" do
      put :update, :id => @location.id, :location => { :description => 'new description' }
      @location.reload
      assert_equal 'new description', @location.description
      assert_redirected_to manage_locations_path
    end

    should "should use default template if custom availability rules were not checked" do
      put :update, :id => @location.id, :location => {
        :availability_template_id=>"custom", 
        :availability_rules_attributes=>availability_rules_params
      }
      @location.reload
      assert_equal 5, @location.availability_rules.count
    end

    should "require availability rule to be opened for at least 1 hour" do
      put :update, :id => @location.id, :location => {
        :availability_template_id=>"custom", 
        :availability_rules_attributes=> { 
          "0" => { "day" => "1", "open_hour" => '9', "close_hour" => '9' } 
        }

      }
      @location = assigns(:location)
      assert !@location.valid?
      assert @location.errors.any? { |e| e.to_s == 'availability_rules.day_1' }
    end

    should "destroy location" do
      stub_mixpanel
      @tracker.expects(:updated_profile_information).with do |user|
        user == @user
      end
      assert_difference('@user.locations.count', -1) do
        delete :destroy, :id => @location.id
      end

      assert_redirected_to manage_locations_path
    end

    context "someone else tries to manage our location" do

      setup do
        @other_user = FactoryGirl.create(:user)
        FactoryGirl.create(:company, :creator => @other_user)
        sign_in @other_user
      end

      should "not create location" do
        stub_mixpanel
        assert_no_difference('@user.locations.count') do
          post :create, { :location => FactoryGirl.attributes_for(:location_in_auckland).reverse_merge!({:location_type_id => @location_type.id})}
        end
      end

      should 'handle lack of permission to edit properly' do
        assert_raise Location::NotFound do
          get :edit, :id => @location.id
        end
      end

      should "not update location" do
        assert_raise Location::NotFound do
          put :update, :id => @location.id, :location => { :description => 'new description' }
        end
      end

      should "not destroy location" do
        assert_raise Location::NotFound do
          delete :destroy, :id => @location.id
        end
      end

      should 'be relogged if he uses token' do
          get :edit, :id => @location.id, :token => @location.creator.authentication_token
          assert_response :success
      end

      should 'be prompted login form if he uses wrong token' do
          get :edit, :id => @location.id, :token => 'this one is certainly wrong one'
          assert_response :redirect
          assert_redirected_to new_user_session_path
      end
    end
  end

  private 

  def availability_rules_params
    @location.availability_rules.each.with_index.inject([]) do |arr, (a, index)|
      arr[index] = { "id" => a.id, "day" => a.day, "_destroy" => "1" }
      arr
    end
  end


end
