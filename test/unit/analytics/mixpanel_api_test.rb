require 'test_helper'

class MixpanelApiTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @mixpanel = stub() # Represents a Mixpanel::Tracker instance from the mixpanel gem
  end

  context '#initialize' do
    should "generate an anonymous identity if no user or anon id" do
      mixpanel = MixpanelApi.new(@mixpanel, :current_user => nil)
      assert mixpanel.anonymous_identity.present?, "Expected to generate an anonymous_identity"
      assert_equal mixpanel.anonymous_identity, mixpanel.distinct_id
    end

    should "use anonymous identity provided if no user" do
      mixpanel = MixpanelApi.new(@mixpanel, :current_user => nil, :anonymous_identity => 500)
      assert_equal 500, mixpanel.anonymous_identity
      assert_equal 500, mixpanel.distinct_id
    end

    should "use store user id as distinct id if user provided" do
      user = stub(:id => 100)
      mixpanel = MixpanelApi.new(@mixpanel, :current_user => user, :anonymous_identity => 500)
      assert_equal 500, mixpanel.anonymous_identity
      assert_equal user, mixpanel.current_user
    end

    should "store current instance id and current domain" do
      request_details_hash = { 'current_instance_id' => 2, 'current_host' => 'www.example.com' }
      mixpanel = MixpanelApi.new(@mixpanel, :request_details => request_details_hash, :anonymous_identity => 500)
      assert_equal 500, mixpanel.anonymous_identity
      assert_equal request_details_hash, mixpanel.request_details
    end

    should 'register campaign parameters as session properties' do
      mixpanel = MixpanelApi.new(@mixpanel, :request_params => { source: 'google', campaign: 'guests' })
      assert_equal 'google', mixpanel.session_properties[:source]
      assert_equal 'guests', mixpanel.session_properties[:campaign]
    end
  end

  context '#distinct_id' do
    should "return the user id if a user is provided" do
      mixpanel = MixpanelApi.new(@mixpanel, :current_user => stub(:id => 100), :anonymous_identity => 500)
      assert_equal 100, mixpanel.distinct_id
    end

    should "return the anonymous_identity if no user is provided" do
      mixpanel = MixpanelApi.new(@mixpanel, :current_user => nil, :anonymous_identity => 500)
      assert_equal 500, mixpanel.distinct_id
    end
  end

  context '#track' do
    should "trigger mixpanel track with distinct_id" do
      name = 'Test Event'
      properties = { 'TestProp' => 'value' }
      wrapper = MixpanelApi.new(@mixpanel)
      expected_properties = properties.merge(:distinct_id => wrapper.distinct_id)
      @mixpanel.expects(:track).with { |_event_name, _properties, _options|
        _event_name == name && _properties == expected_properties
      }

      wrapper.track(name, properties)
    end

    should "apply session properties" do
      name = 'Test Event'
      properties = { 'TestProp' => 'value' }
      wrapper = MixpanelApi.new(@mixpanel, :request_params => { :source => "google" })
      expected_properties = properties.merge(:distinct_id => wrapper.distinct_id, :source => "google").stringify_keys
      @mixpanel.expects(:track).with { |_event_name, _properties, _options|
        _event_name == name && _properties.stringify_keys == expected_properties
      }

      wrapper.track(name, properties)
    end

    should "apply request details" do
      name = 'Test Event'
      properties = { 'TestProp' => 'value' }
      request_details_hash = { 'current_instance_id' => 2, 'current_host' => 'www.example.com' }
      wrapper = MixpanelApi.new(@mixpanel, :request_details => request_details_hash)
      expected_properties = properties.merge(:distinct_id => wrapper.distinct_id, :current_instance_id => 2, :current_host => 'www.example.com').stringify_keys
      @mixpanel.expects(:track).with { |_event_name, _properties, _options|
        _event_name == name && _properties.stringify_keys == expected_properties
      }

      wrapper.track(name, properties)
    end

    context '#desksnearme employee' do

      setup do
        MixpanelApi.any_instance.stubs(:should_not_track_employees?).returns(true)
      end

      should 'not track if current user has email *@desksnear.me' do 
        mixpanel = MixpanelApi.new(@mixpanel)
        @mixpanel.expects(:alias).once
        @mixpanel.expects(:track).never
        mixpanel.apply_user(FactoryGirl.create(:user, email: 'maciej@desksnear.me') , :alias => true)
        mixpanel.track('Event', {})
      end

      should 'not track if current user has email *@parchard.com' do 
        mixpanel = MixpanelApi.new(@mixpanel)
        @mixpanel.expects(:alias).once
        @mixpanel.expects(:track).never
        mixpanel.apply_user(FactoryGirl.create(:user, email: 'sai+213123@perchard.com') , :alias => true)
        mixpanel.track('Event', {})
      end

      should "not track if current user's email belongs to employee" do 
        mixpanel = MixpanelApi.new(@mixpanel)
        @mixpanel.expects(:alias).once
        @mixpanel.expects(:track).never
        mixpanel.apply_user(FactoryGirl.create(:user, email: 'krajek6@gmail.com') , :alias => true)
        mixpanel.track('Event', {})
      end

    end

  end

  context '#apply_user' do
    should "clear any anonymous id and alias for the user id" do
      user = stub(:id => 100)
      mixpanel = MixpanelApi.new(@mixpanel)
      anon_id = mixpanel.anonymous_identity
      @mixpanel.expects(:alias).with { |new_distinct_id, options| new_distinct_id == user.id && options[:distinct_id] == anon_id }

      mixpanel.apply_user(user, :alias => true)
      assert_nil mixpanel.anonymous_identity
      assert_equal user.id, mixpanel.distinct_id
    end

    should "not alias if :alias is false or not provided" do
      @mixpanel.expects(:alias).never

      MixpanelApi.new(@mixpanel).apply_user(stub())
    end
  end

  context '#set_person_properties' do
    should "trigger a mixpanel set with the properties" do
      user = stub(:id => 100)
      properties = { 'Test' => '1', 'Another' => 'value' }
      @mixpanel.expects(:set).with { |distinct_id, props| distinct_id == user.id && props == properties }

      MixpanelApi.new(@mixpanel, :current_user => user).set_person_properties(properties)
    end
  end


end
