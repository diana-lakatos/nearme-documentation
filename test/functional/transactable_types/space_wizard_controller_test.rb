require 'test_helper'
require 'vcr_setup'

class TransactableTypes::SpaceWizardControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @industry = FactoryGirl.create(:industry)

    sign_in @user
    FactoryGirl.create(:location_type)
    @partner = FactoryGirl.create(:partner)

    @transactable_type = FactoryGirl.create(:transactable_type_listing)
  end

  context 'scopes current partner for new company' do
    should 'match partner_id' do
      PlatformContext.current = PlatformContext.new(@partner)
      @user = FactoryGirl.create(:user)
      sign_in @user
      stub_us_geolocation
      assert_difference 'Transactable.count' do
        post :submit_listing, get_params
      end
      @company = Company.last
      assert_equal @partner.id, @company.partner_id
    end
  end

  should 'set correct foreign keys' do
    stub_us_geolocation
    assert_difference 'Transactable.count' do
      post :submit_listing, get_params
    end
    @company = Company.last
    instance_id = @company.instance_id
    creator_id = @company.creator_id
    @company.locations.each do |location|
      assert_equal instance_id, location.instance_id
      assert_equal creator_id, location.creator_id
      location.listings.each do |listing|
        assert_equal instance_id, location.instance_id
        assert_equal creator_id, location.creator_id
      end
    end
  end

  context "price must be formatted" do

    should 'be able to handle 1 to 1 unit to subunit conversion date passed manually' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(daily_price: "25", currency: 'JPY')
      end
      @listing = assigns(:listing)
      assert_equal 25.to_money('JPY'), @listing.daily_price
      assert_equal 25, @listing.daily_price_cents
    end

    should 'be able to handle 5 to 1 unit to subunit conversion date passed manually' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(daily_price: "25", currency: 'MGA')
      end
      @listing = assigns(:listing)
      assert_equal 25.to_money('MGA'), @listing.daily_price
      assert_equal 125, @listing.daily_price_cents
    end

    should 'be able to handle 5 to 1 unit to subunit conversion if it is default currency' do
      stub_us_geolocation
      PlatformContext.current.instance.update_attribute(:default_currency, 'MGA')
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(daily_price: "25", currency: '')
      end
      @listing = assigns(:listing)
      assert_equal 25.to_money('MGA'), @listing.daily_price
      assert_equal 125, @listing.daily_price_cents
    end

    should "ignore invalid characters in price" do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(daily_price: "249.31-300.00", weekly_price: '!@#$%^&*()_+=_:;"[]}{\,<.>/?`~', monthly_price: 'i am not valid price I guess', free: "0")
      end
      @listing = assigns(:listing)
      assert_equal 24931, @listing.daily_price_cents
      assert_equal 0, @listing.weekly_price_cents
      assert_equal 0, @listing.monthly_price_cents
    end

    should "handle nil and empty prices" do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(daily_price: nil, weekly_price: "", monthly_price: "249.00", free: "0")
      end
      @listing = assigns(:listing)
      assert_nil @listing.daily_price
      assert_nil @listing.weekly_price
      assert_equal 24900, @listing.monthly_price_cents
    end

    should "not raise exception if hash is incomplete" do
      assert_no_difference('Transactable.count') do
        post :submit_listing, { transactable_type_id: @transactable_type.id, "user" => {"companies_attributes" => {"0"=> { "name"=>"International Secret Intelligence Service" }}}}
      end
    end


  end

  context "geo-located default country" do
    setup do
      @user.country_name = nil
      @user.save!
    end

    should "be set to Greece" do
      VCR.use_cassette "freegeoip_greece" do
        FactoryGirl.create(:country, name: "Greece", iso: "GR")
        # Set request ip to an ip address in Greece
        @request.env['REMOTE_ADDR'] = '2.87.255.255'
        get :list, transactable_type_id: @transactable_type.id
        assert assigns(:country) == "Greece"
        assert_select 'option[value="Greece"][selected="selected"]', 1
      end
    end

    should "be set to Brazil" do
      VCR.use_cassette "freegeoip_brazil" do
        FactoryGirl.create(:country, name: "Brazil", iso: "BR")
        # Set request ip to an ip address in Brazil
        @request.env['REMOTE_ADDR'] = '139.82.255.255'
        get :list, transactable_type_id: @transactable_type.id
        assert assigns(:country) == "Brazil"
        assert_select 'option[value="Brazil"][selected="selected"]', 1
      end
    end

  end

  context 'verification file' do
    context 'instance requires verification' do

      setup do
        FactoryGirl.create(:approval_request_template, required_written_verification: true)
        FactoryGirl.create(:form_component, form_componentable: @transactable_type)
        @user.update! created_at: 1.minute.from_now
      end

      should 'show form to write message'  do
        get :list, transactable_type_id: @transactable_type.id
        assert_select '#user_approval_requests_attributes_0_message', 1
      end
    end

    context 'instance does not require verification' do

      should 'not show form to write message'  do
        get :list, transactable_type_id: @transactable_type.id
        assert_select '#user_approval_requests_attributes_0_message', false
      end
    end

  end

  context 'track' do

    should "track location and listing creation" do
      Rails.application.config.event_tracker.any_instance.expects(:created_a_location).with do |location, custom_options|
        location == assigns(:location) && custom_options == { via: 'wizard' }
      end
      Rails.application.config.event_tracker.any_instance.expects(:created_a_listing).with do |listing, custom_options|
        listing == assigns(:listing) && custom_options == { via: 'wizard' }
      end
      Rails.application.config.event_tracker.any_instance.expects(:created_a_company).with do |company, custom_options|
        company == assigns(:company)
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == @user
      end

      stub_us_geolocation
      post :submit_listing, get_params
    end

    should "track draft creation" do
      Rails.application.config.event_tracker.any_instance.expects(:saved_a_draft)
      stub_us_geolocation
      post :submit_listing, get_params.merge({"save_as_draft"=>"Save as draft"})
    end

    should 'track clicked list your bookable when logged in' do
      Rails.application.config.event_tracker.any_instance.expects(:clicked_list_your_bookable)
      get :new, transactable_type_id: @transactable_type.id
    end

    should 'track clicked list your bookable when not logged in' do
      sign_out @user
      Rails.application.config.event_tracker.any_instance.expects(:clicked_list_your_bookable)
      get :new, transactable_type_id: @transactable_type.id
    end


    should 'track viewed list your bookable' do
      Rails.application.config.event_tracker.any_instance.expects(:viewed_list_your_bookable)
      get :list, transactable_type_id: @transactable_type.id
    end

    context '#user has already bookable' do

      setup do
        @listing = FactoryGirl.create(:transactable)
        @listing.company.tap { |c| c.creator = @user }.save!
        @listing.company.add_creator_to_company_users
      end

      should 'not track clicked list your bookable if user already has bookable ' do
        Rails.application.config.event_tracker.any_instance.expects(:clicked_list_your_bookable).never
        get :new, transactable_type_id: @transactable_type.id
      end

      should 'not track viewed list your bookable if user already has bookable ' do
        Rails.application.config.event_tracker.any_instance.expects(:viewed_list_your_bookable).never
        get :list, transactable_type_id: @transactable_type.id

      end

    end

  end

  context 'GET new' do
    should 'redirect to manage listings page if has listings' do
      create_listing
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to new location if no listings' do
      create_listing
      @location.destroy
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to new listing if no listings but with one location' do
      create_listing
      @listing.destroy
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to dashboard if no listings but more than one location' do
      create_listing
      @listing.destroy
      FactoryGirl.create(:location, :company => @company)
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to space wizard list if no listings' do
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to transactable_type_space_wizard_list_url(@transactable_type)
    end

    should 'redirect to registration path if not logged in' do
      sign_out @user
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to new_user_registration_url(:wizard => 'space', :return_to => transactable_type_space_wizard_list_url(@transactable_type))
    end
  end

  context 'with multiple sections' do
    should 'render all sections correctly' do
      FactoryGirl.create(:form_component, form_componentable: @transactable_type, form_fields: [{'company' => 'name'}, {'company' => 'address'}, {'location' => 'name'}], name: 'Super Cool Section 1')
      FactoryGirl.create(:form_component, form_componentable: @transactable_type, form_fields: [{ 'transactable' => 'price' }, { 'transactable' => 'photos' }, { 'transactable' => 'name' }], name: 'Transactable Section')
      FactoryGirl.create(:form_component, form_componentable: @transactable_type, form_fields: [{'user' => 'phone'}], name: 'Contact Information')
      get :list, transactable_type_id: @transactable_type.id
      assert_select "h2", 'Super Cool Section 1'
      assert_select "h2", 'Transactable Section'
      assert_select "h2", 'Contact Information'
      assert_select '#user_phone'
    end
  end

  context 'with skip_company' do
    setup do
      @instance_with_skip_company = FactoryGirl.create(:instance, skip_company: true)
      @domain = FactoryGirl.create(:domain, target: @instance_with_skip_company)

      PlatformContext.current = PlatformContext.new(@instance_with_skip_company)
      @user = FactoryGirl.create(:user)
      sign_in @user
      @transactable_type = FactoryGirl.create(:transactable_type_listing)

      @params_without_company_name = get_params
      @params_without_company_name['user']['companies_attributes']['0'].delete('name')
      @params_without_company_name['user']['companies_attributes']['0'].delete('industry_ids')
    end

    should 'create listing when location skip_company is set to true' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, @params_without_company_name
      end
    end

    should 'create listing when location skip_company is set to true and address is missing' do
      stub_us_geolocation
      @params_without_company_name['user']['companies_attributes']['0'].delete('company_address_attributes')

      assert_difference('Transactable.count', 1) do
        post :submit_listing, @params_without_company_name
      end

      company = Company.last
      assert_equal company.latitude, 37.09024
      assert_equal company.longitude, -95.712891
    end

    context 'with skip_location' do
      setup do
        @transactable_type.update_attribute :skip_location, true
      end

      should 'create listing when location skip_company is set to true and address is missing' do
        stub_us_geolocation

        @params_without_company_name['user']['companies_attributes']['0'].delete('company_address_attributes')

        assert_difference('Location.count', 1) do
          post :submit_listing, @params_without_company_name
        end

        company = Company.last
        location = Location.last
        assert_equal 37.09024, company.latitude
        assert_equal -95.712891, company.longitude
        assert_equal 5, location.latitude
        assert_equal 8, location.longitude
      end

      should 'create listing with company address when location skip_company and skip_listing set' do
        stub_us_geolocation
        @params_without_company_name['user']['companies_attributes']['0'].delete('company_address_attributes')
        @params_without_company_name['user']['companies_attributes']['0']['locations_attributes']['0'].delete('location_address_attributes')

        assert_difference('Location.count', 1) do
          post :submit_listing, @params_without_company_name
        end
      end
    end
  end

  context 'schedule bookings' do
    should 'not have duplicated schedule expiration rules' do
      stub_us_geolocation
      params = get_params(booking_type: 'schedule', fixed_price: 1000)
      params['user']['companies_attributes']["0"]['locations_attributes']["0"]['listings_attributes']["0"]["schedule_attributes"] = {
        "sr_start_datetime(1i)"=>"2015",
        "sr_start_datetime(2i)"=>"8",
        "sr_start_datetime(3i)"=>"5",
        "sr_start_datetime(4i)"=>"12",
        "sr_start_datetime(5i)"=>"36",
        "sr_every_hours"=>"2",
        "sr_from_hour(1i)"=>"2015",
        "sr_from_hour(2i)"=>"8",
        "sr_from_hour(3i)"=>"5",
        "sr_from_hour(4i)"=>"12",
        "sr_from_hour(5i)"=>"36",
        "sr_to_hour(1i)"=>"2015",
        "sr_to_hour(2i)"=>"8",
        "sr_to_hour(3i)"=>"5",
        "sr_to_hour(4i)"=>"12",
        "sr_to_hour(5i)"=>"36",
        "sr_days_of_week"=>["1","2"],
        "use_simple_schedule"=>"1",
        "schedule"=>
         "{\"start_date\":\"2015-03-03T04:49:00.000Z\",\"rrules\":[{\"rule_type\":\"IceCube::WeeklyRule\",\"interval\":1,\"validations\":{\"day\":[1,5]}}]}",
        "schedule_exception_rules_attributes"=>
         {"1438778184391"=>
           {"label"=>"Aaaa",
            "duration_range_start(1i)"=>"2015",
            "duration_range_start(2i)"=>"8",
            "duration_range_start(3i)"=>"5",
            "duration_range_start(4i)"=>"12",
            "duration_range_start(5i)"=>"00",
            "duration_range_end(1i)"=>"2015",
            "duration_range_end(2i)"=>"8",
            "duration_range_end(3i)"=>"5",
            "duration_range_end(4i)"=>"12",
            "duration_range_end(5i)"=>"00",
            "_destroy"=>"false"}}}

      post :submit_listing, params
      @listing = assigns(:listing)
      assert_equal 1, @listing.schedule.schedule_exception_rules.length
    end
  end

  private

  def get_params(options = {})
    free = options[:daily_price].to_f + options[:weekly_price].to_f + options[:monthly_price].to_f == 0
    options.reverse_merge!(daily_price: nil, weekly_price: nil, monthly_price: nil, free: free, currency: 'USD')
    {"user" =>
     {"companies_attributes"=>
      {"0" =>
       {
         "name"=>"International Secret Intelligence Service",
         "company_address_attributes" => {
           "address" => "Poznań, Polska",
           "latitude" => "52.406374",
           "longitude" => "16.925168100000064",
         },
         "industry_ids"=>["#{@industry.id}"],
         "locations_attributes"=>
         {"0"=>
          {
            "description"=>"Our historic 11-story Southern Pacific Building, also known as \"The Landmark\", was completed in 1916. We are in the 172 m Spear Tower.",
            "name" => 'Location',
            "location_type_id"=>"1",
            "location_address_attributes" =>
            {
              "address"=>"usa",
              "local_geocoding"=>"10",
              "latitude"=>"5",
              "longitude"=>"8",
              "formatted_address"=>"formatted usa",
            },
            "listings_attributes"=>
            {"0"=>
             {
               "transactable_type_id" => TransactableType.first.id,
               "name"=>"Desk",
               "description"=>"We have a group of several shared desks available.",
               "action_hourly_booking" => false,
               "quantity"=>"1",
               "booking_type" => options[:booking_type] || 'regular',
               "daily_price"=>options[:daily_price],
               "fixed_price"=>options[:fixed_price],
               "weekly_price"=>options[:weekly_price],
               "monthly_price"=> options[:monthly_price],
               "action_free_booking"=>options[:free],
               "confirm_reservations"=>"0",
               "photos_attributes" => [FactoryGirl.attributes_for(:photo)],
               "currency"=>options[:currency],
               "properties" => {
                 "listing_type"=>"Desk",
               }
             }
            },
          }
         }
       },
      },
      "country_name" => "United States",
      "phone" => "123456789"
     },
     transactable_type_id: @transactable_type.id
    }
  end

  def create_listing
    @company = FactoryGirl.create(:company, :creator => @user)
    @location = FactoryGirl.create(:location, :company => @company)
    @listing = FactoryGirl.create(:transactable, :location => @location)
  end
end

