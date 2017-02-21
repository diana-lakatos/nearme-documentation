require 'test_helper'
require 'helpers/gmaps_fake'

class DataImporter::XmlFileTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    stub_image_url('http://www.example.com/image.jpg')
    stub_image_url('http://www.example.com/photo.jpg')
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    FactoryGirl.create(:instance_profile_type)
    @location_type = FactoryGirl.create(:location_type, name: 'My Type')
  end

  context 'data persistance' do
    setup do
      @xml_file = FactoryGirl.create(:xml_template_file)
      @xml_file.parse
    end

    should 'counts should not change after second parse' do
      expected_counts = get_counts_of_all_relevant_objects
      @xml_file.parse
      get_counts_of_all_relevant_objects.each do |k, v|
        assert_equal expected_counts[k], v, "#{k} count changed after second parsing (duplicated?)"
      end
    end

    context '#users' do
      should 'create the right number of users' do
        assert_equal 2, @instance.users.count
      end

      should 'should have the right amount of companies' do
        assert_equal ['1'], User.find_by(email: 'user1@example.com').companies.pluck(:external_id).sort
        assert_equal %w(1 2), User.find_by(email: 'user2@example.com').companies.pluck(:external_id).sort
      end

      context '#companies' do
        should 'create the right amount of companies' do
          assert_equal 2, @instance.companies.count
        end

        should '1 should have the right details' do
          @company = @instance.companies.find_by(external_id: '1')
          assert_equal "My Company's", @company.name
          assert_equal 'http://www.mycompany.example.com', @company.url
          assert_equal 'company@example.com', @company.email
        end

        should '2 should have the right details' do
          @company = @instance.companies.find_by(external_id: '2')
          assert_equal "My second Company's", @company.name
        end

        context '#locations' do
          should 'create right amount of locations for first company' do
            assert_equal 2, @instance.companies.find_by(external_id: '1').locations.count
          end

          should 'create right amount of locations for second company' do
            assert_equal 1, @instance.companies.find_by(external_id: '2').locations.count
          end

          should 'not aggregate locations with the same address that belong to different companies' do
            assert_equal 2, @instance.locations.joins(:location_address).where('addresses.address like ?', '%Pulawska%').count
          end

          context 'location at Ursynowska' do
            setup do
              @location = @instance.locations.joins(:location_address).where('addresses.address like ?', '%Ursynowska%').first
            end

            should 'create the right details for location at Ursynowska' do
              assert_equal 'Ursynowska 1, 02-605 Warsaw, Poland', @location.address
              assert_nil @location.address2
              assert_equal 'Warsaw', @location.city
              assert_equal 'Masovian Voivodeship', @location.state
              assert_equal '02-605', @location.postcode
              assert_equal 'Be careful, cool place!', @location.special_notes
              assert_equal 'location@example.com', @location.email
              assert_equal 'This is my cool location', @location.description
            end

            context '#listing' do
              should 'create the right amount of listing 1' do
                assert_equal 2, @location.listings.count
              end

              should 'have the right details (listing1)' do
                @listing = @location.listings.find_by(external_id: '1')
                assert @listing.confirm_reservations
                assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                assert_equal 10, @listing.action_type.price_cents_for('1_day')
                assert_equal 15, @listing.action_type.price_cents_for('7_day')
                assert_equal 30, @listing.action_type.price_cents_for('30_day')
                assert @listing.enabled
                assert_equal 'my attrs! 1', @listing.properties.my_attribute
              end

              should 'have the right details (listing2)' do
                @listing = @location.listings.find_by(external_id: '2')
                assert @listing.confirm_reservations
                assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                assert_equal 10, @listing.action_type.price_cents_for('1_day')
                assert_equal 15, @listing.action_type.price_cents_for('7_day')
                assert_equal 30, @listing.action_type.price_cents_for('30_day')
                assert @listing.enabled
                assert_equal 'my attrs! 2', @listing.properties.my_attribute
              end

              context '#photos' do
                should 'have correct original url' do
                  assert_equal ['http://www.example.com/image.jpg', 'http://www.example.com/photo.jpg'], @location.listings.find_by(external_id: '1').photos.pluck(:image_original_url).sort
                  assert_equal ['http://www.example.com/photo.jpg'], @location.listings.find_by(external_id: '2').photos.pluck(:image_original_url).sort
                end
              end
            end
          end

          context 'location at Pulawska' do
            setup do
              @location = @instance.locations.joins(:location_address).where('addresses.address like ?', '%Pulawska%').first
            end

            should 'create the right details for location at Pulawska' do
              assert_equal 'Puławska 34, Warsaw, Poland', @location.address
              assert_nil @location.address2
              assert_equal 'Warsaw', @location.city
              assert_equal 'Masovian Voivodeship', @location.state
              assert_nil @location.postcode
              assert_equal 'Be careful, cool2 place!', @location.special_notes
              assert_equal 'location2@example.com', @location.email
              assert_equal 'This is my cool2 location', @location.description
            end

            context '#listing' do
              should 'create the right amount of listings for location at Pulawska' do
                assert_equal 1, @location.listings.count
              end

              should 'have the right details (listing3)' do
                @listing = @location.listings.find_by(external_id: '3')
                assert @listing.confirm_reservations
                assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                assert_equal 10, @listing.action_type.price_cents_for('1_day')
                assert_equal 15, @listing.action_type.price_cents_for('7_day')
                assert_equal 30, @listing.action_type.price_cents_for('30_day')
                assert @listing.enabled
                assert_equal 'my attrs! 3', @listing.properties.my_attribute
              end

              context '#' do
                should 'have correct original url (photo belonging to listing 3)' do
                  assert_equal ['http://www.example.com/photo.jpg'], @location.listings.find_by(external_id: '3').photos.pluck(:image_original_url).sort
                end
              end
            end
          end
        end
      end
    end
  end

  context 'sending invitational emails' do
    setup do
      Utils::DefaultAlertsCreator::SignUpCreator.new.create_all!
    end

    should 'do not send emails if setting is off' do
      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        @xml_file = FactoryGirl.create(:xml_template_file)
        @xml_file.parse
      end
    end

    should 'send emails only once to users if settting is on' do
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
      @xml_file = FactoryGirl.create(:xml_template_file_send_invitations)
      assert_difference('ActionMailer::Base.deliveries.count', 2) do
        @xml_file.parse
      end
    end
  end

  context 'host template' do
    setup do
      @xml_file = FactoryGirl.create(:host_xml_template_file)
    end

    context 'persist data' do
      setup do
        @xml_file.parse
      end

      context '#users' do
        should 'create the right number of users' do
          assert_equal 1, @instance.users.count
        end

        should 'should have the right amount of companies' do
          assert_equal ['user-name@example.com'], User.find_by(email: 'user-name@example.com').companies.pluck(:external_id).sort
        end

        context '#companies' do
          setup do
            @company = @instance.companies.find_by(external_id: 'user-name@example.com')
          end

          should 'create the right amount of companies' do
            assert_equal 1, @instance.companies.count
          end

          should '1 should have the right details' do
            assert_equal 'UserName UserLast', @company.name
          end

          context '#locations' do
            should 'create right amount of locations for first company' do
              assert_equal 2, @company.locations.count
            end

            context 'location at Ursynowska' do
              setup do
                @location = @instance.locations.joins(:location_address).where('addresses.address like ?', '%Ursynowska%').first
              end

              should 'create the right details for location at Ursynowska' do
                assert_equal 'Ursynowska 1, 02-605 Warsaw, Poland', @location.address
                assert_nil @location.address2
                assert_equal 'Warsaw', @location.city
                assert_equal 'Masovian Voivodeship', @location.state
                assert_equal '02-605', @location.postcode
                assert_equal 'Be careful, cool place!', @location.special_notes
                assert_equal 'location@example.com', @location.email
                assert_equal 'This is my cool location', @location.description
              end

              context '#listing' do
                should 'create the right amount of listing 1' do
                  assert_equal 2, @location.listings.count
                end

                should 'have the right details (listing1)' do
                  @listing = @location.listings.find_by(external_id: '1')
                  assert @listing.confirm_reservations
                  assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                  assert_equal 10, @listing.action_type.price_cents_for('1_day')
                  assert_equal 15, @listing.action_type.price_cents_for('7_day')
                  assert_equal 30, @listing.action_type.price_cents_for('30_day')
                  assert @listing.enabled
                  assert_equal 'my attrs! 1', @listing.properties.my_attribute
                end

                should 'have the right details (listing2)' do
                  @listing = @location.listings.find_by(external_id: '2')
                  assert @listing.confirm_reservations
                  assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                  assert_equal 10, @listing.action_type.price_cents_for('1_day')
                  assert_equal 15, @listing.action_type.price_cents_for('7_day')
                  assert_equal 30, @listing.action_type.price_cents_for('30_day')
                  assert @listing.enabled
                  assert_equal 'my attrs! 2', @listing.properties.my_attribute
                end

                context '#photos' do
                  should 'have correct original url' do
                    assert_equal ['http://www.example.com/image.jpg', 'http://www.example.com/photo.jpg'], @location.listings.find_by(external_id: '1').photos.pluck(:image_original_url).sort
                    assert_equal ['http://www.example.com/photo.jpg'], @location.listings.find_by(external_id: '2').photos.pluck(:image_original_url).sort
                  end
                end
              end
            end

            context 'location at Pulawska' do
              setup do
                @location = @instance.locations.joins(:location_address).where('addresses.address like ?', '%Pulawska%').first
              end

              should 'create the right details for location at Pulawska' do
                assert_equal 'Puławska 34, Warsaw, Poland', @location.address
                assert_nil @location.address2
                assert_equal 'Warsaw', @location.city
                assert_equal 'Masovian Voivodeship', @location.state
                assert_nil @location.postcode
                assert_equal 'Be careful, cool2 place!', @location.special_notes
                assert_equal 'location2@example.com', @location.email
                assert_equal 'This is my cool2 location', @location.description
              end

              context '#listing' do
                should 'create the right amount of listings for location at Pulawska' do
                  assert_equal 2, @location.listings.count
                end

                should 'have the right details (listing3)' do
                  @listing = @location.listings.find_by(external_id: '3')
                  assert @listing.confirm_reservations
                  assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                  assert_equal 10, @listing.action_type.price_cents_for('1_day')
                  assert_equal 15, @listing.action_type.price_cents_for('7_day')
                  assert_equal 30, @listing.action_type.price_cents_for('30_day')
                  assert @listing.enabled
                  assert_equal 'my attrs! 3', @listing.properties.my_attribute
                end

                should 'have correct original url (photo belonging to listing 3)' do
                  assert_equal ['http://www.example.com/photo.jpg'], @location.listings.find_by(external_id: '3').photos.pluck(:image_original_url).sort
                end

                should 'have the right details (listing4)' do
                  @listing = @location.listings.find_by(external_id: '4')
                  assert @listing.confirm_reservations
                  assert_equal 4, @listing.action_type.price_cents_for('1_hour')
                  assert_equal 10, @listing.action_type.price_cents_for('1_day')
                  assert_equal 15, @listing.action_type.price_cents_for('7_day')
                  assert_equal 30, @listing.action_type.price_cents_for('30_day')
                  assert @listing.enabled
                  assert_equal 'my attrs! 4', @listing.properties.my_attribute
                end
              end
            end
          end
        end
      end
    end
  end

  def get_absolute_file_path(name)
    Rails.root.join('test', 'assets', 'data_importer') + name
  end

  def get_counts_of_all_relevant_objects
    { instance: Instance.count,
      user: User.count,
      company: Company.count,
      location: Location.count,
      address: Address.count,
      location_availability_rules: AvailabilityRule.where(target_type: 'Location').count,
      listing_availability_rules: AvailabilityRule.where(target_type: 'Transactable').count,
      listing: Transactable.count,
      photo: Photo.count }
  end
end
