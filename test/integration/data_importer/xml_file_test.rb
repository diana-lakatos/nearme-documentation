require 'vcr_setup'
require 'test_helper'

class CarrierWave::Mount::Mounter
  def store!
  end

  def store
  end

  def download!
  end

  def download
  end
end


class DataImporter::XmlFileTest < ActiveSupport::TestCase

  describe 'skip those tests for now' do 
    context '#instances' do
      setup do
        Photo.any_instance.stubs(:remote_image_url=)
        ListingType.create(:name => 'Office Space')
        ListingType.create(:name => 'Meeting Room')
        LocationType.create(:name => 'Business')
        Industry.create(:name => 'Commercial Real Estate')
        [ "Administrative Assistant", "Catering", "Coffee/Tea", "Videoconferencing Facilities",
          "Copier", "Fax", "Projector", "Telephone", "Printer", "Scanner", "Television", "Yard Area",
          "Parking", "Lounge Area", "Internet Access", "Wi-Fi", "Whiteboard", ].each { |name| Amenity.create(:name => name) }
        @xml_file = DataImporter::XmlFile.new(get_absolute_file_path('data.xml'))

        VCR.use_cassette('data_import') do
          @xml_file.parse
        end
      end

      should 'not create duplicates when parsed again' do
        expected_count = get_counts_of_all_relevant_objects
        VCR.use_cassette('data_import') do
          @xml_file.parse
        end
        get_counts_of_all_relevant_objects.each do |k, v|
          assert_equal expected_count[k], v, "#{k.to_s} count changed after second parsing (duplicated?)"
        end
      end

      should 'create instance with right name' do
        assert_equal 'PBCenter', Instance.last.name
      end

      should 'should create only one instance' do
        assert_equal 1, Instance.find_all_by_name('PBCenter').count
      end

      context '#users' do

        setup do
          @instance = Instance.find_by_name('PBCenter')
        end

        should 'create the right number of users' do
          assert_equal 3, @instance.users.count
        end

        should 'should have companies assigned' do
          @instance.users.each do |u|
            assert_equal u.email.downcase, u.companies.first.email.downcase, "Something is wrong with email of company #{u.companies.first.external_id}"
          end
        end

        should 'should have right details' do
          assert_equal ['United States'], @instance.users.pluck(:country_name).uniq
          assert_equal "213-943-1300", User.find_by_email("355manager@pbcenters.com").phone
          assert_equal "310-496-4490", User.find_by_email("sm1manager@pbcenters.com").phone
          assert_equal "562-983-8000", User.find_by_email("wtcmanager@pbcenters.com").phone
        end

        should 'should have the right amount of companies' do
          @instance.users.each do |u|
            assert_equal 1, u.companies.count, "User #{u.email} has multiple companies: #{u.companies.pluck(:external_id)}"
          end

        end

        context '#companies' do

          should 'create the right amount of companies' do
            assert_equal 3, @instance.companies.count
          end

          should '355 should have the right details' do
            @company = @instance.companies.find_by_external_id('355')
            assert_equal 'WELLS FARGO CENTER - KPMG BUILDING', @company.name
            assert_equal 'Center is located between 3rd and 4th street and between Hope St and Grand Ave. Entrance for parking structure of the Building is on Hope Ave.', @company.description
          end

          should 'SM1 should have the right details' do
            @company = @instance.companies.find_by_external_id('SM1')
            assert_equal 'BROADWAY PLAZA', @company.name
            assert_equal '', @company.description
          end

          should 'WTC should have the right details' do
            @company = @instance.companies.find_by_external_id('WTC')
            assert_equal 'WORLD TRADE CENTER', @company.name
            assert_equal '', @company.description
          end

          context '#industries' do

            should 'assign right industries' do
              assert_equal ['Commercial Real Estate'], @instance.companies.last.industries.pluck(:name) 
            end
          end

          context '#locations' do

            should 'create right amount of locations for first company' do
              assert_equal 2, @instance.companies.find_by_external_id('355').locations.count
            end

            should 'create right amount of locations for second company' do
              assert_equal 1, @instance.companies.find_by_external_id('SM1').locations.count
            end

            should 'create right amount of locations for third company' do
              assert_equal 1, @instance.companies.find_by_external_id('WTC').locations.count
            end

            should 'not aggregate locations with the same address that belong to different companies' do
              assert_equal 2, @instance.locations.where('address like ?', "%520 Broadway%").count            
            end

            should 'aggregate locations with the same address within the same company' do
              assert_equal 1, @instance.locations.where('address like ?', "%One World Trade Center%").count
            end

            context 'location at Grand Ave' do

              setup do
                @location = @instance.locations.where('address like ?', "%355 S. Grand Ave%").first
              end

              should 'create the right details for location at 355 S. Grand Ave' do
                assert_equal '355 S. Grand Ave, Suite 2450, Los Angeles, CA, 90071', @location.address
                assert_equal 'Suite 2450', @location.address2
                assert_equal 'Los Angeles', @location.city
                assert_equal 'CA', @location.state
                assert_equal '90071', @location.postcode
                assert_equal "Please provide us with a list of all names of guests who will be attending. We must provide this list to Security. All guests must check in with security and provide Photo ID.\nParking Rates: $4 per 10 minutes, $40.00 Maximum per day Valet Parking", @location.special_notes
                assert_equal '355manager@pbcenters.com', @location.email
                assert_equal '213-943-1300', @location.phone
                assert_equal 'Center is located between 3rd and 4th street and between Hope St and Grand Ave. Entrance for parking structure of the Building is on Hope Ave.', @location.description
              end

              should 'correctly aggregate amenities from all listings that belong to S. Grand Ave' do
                assert_equal ["Administrative Assistant", "Coffee/Tea", "Copier",
                              "Fax", "Telephone", "Printer", "Scanner", "Television",
                              "Yard Area", "Internet Access", "Wi-Fi", "Whiteboard"], @location.amenities.pluck(:name)
              end

              should 'have availability rules for right days' do
                assert_equal [1,2,3,4,5], @location.availability_rules.pluck(:day).sort
              end

              should 'be open at the right time' do
                @location.availability_rules.each do |ar|
                  assert_equal 8, ar.open_hour
                  assert_equal 30, ar.open_minute
                  assert_equal 17, ar.close_hour
                  assert_equal 0, ar.close_minute
                end
              end

              context '#listing' do
                setup do
                  @listing = @location.listings.first
                end

                should 'create the right amount of listings' do
                  assert_equal 1, @location.listings.count
                end

                should 'have right opening hours that differ from location' do
                  @listing.availability_rules.each do |ar|
                    assert_equal 8, ar.open_hour
                    assert_equal 30, ar.open_minute
                    assert_equal 17, ar.close_hour
                    assert_equal 0, ar.close_minute
                  end
                end

                should 'have the right details' do
                  assert_equal 'Large Conference Room', @listing.name
                  assert_equal 'Large Conference Room, seats 12, Beautiful City Views', @listing.description
                  assert_equal 12, @listing.quantity
                  assert_equal 7500, @listing.hourly_price_cents
                  assert_equal 52500, @listing.daily_price_cents
                end

                should 'have the right listing type' do
                  assert_equal 'Meeting Room', @listing.listing_type.name
                end

                context '#photos' do

                  should 'have the right photos' do
                    #assert_equal 1, @listing.photos.count
                  end

                end

              end

            end

            context 'location at WTC' do
              setup do
                @location = @instance.locations.where('address like ?', "%World Trade Center%").first
              end

              should 'create the right details for location at WTC' do
                assert_equal 'One World Trade Center, Suite 800, Long Beach, CA, 90802', @location.address
                assert_equal 'Suite 800', @location.address2
                assert_equal 'Long Beach', @location.city
                assert_equal 'CA', @location.state
                assert_equal '90802', @location.postcode
                assert_equal '$1.80/15 MIN $7.20/HR $18.00/ALL DAY (2HRS 30MIN+)', @location.special_notes
                assert_equal 'wtcmanager@pbcenters.com', @location.email.downcase
                assert_equal '562-983-8000', @location.phone
                assert_equal '', @location.description
              end

              should 'correctly aggregate amenities from all listings that belong to WTC' do
                assert_equal ["Administrative Assistant", "Catering", "Coffee/Tea","Copier", 
                              "Fax","Internet Access" , "Lounge Area", "Printer","Projector", "Scanner","Telephone",
                              "Videoconferencing Facilities", "Whiteboard", "Wi-Fi", "Yard Area"], @location.amenities.pluck(:name).sort
              end

              should 'have availability rules for right days' do
                assert_equal [1,2,3,4,5], @location.availability_rules.pluck(:day).sort
              end

              should 'be open at the right time' do
                @location.availability_rules.each do |ar|
                  assert_equal 8, ar.open_hour
                  assert_equal 30, ar.open_minute
                  assert_equal 17, ar.close_hour
                  assert_equal 0, ar.close_minute
                end
              end

              context '#listing' do
                setup do
                  @listing = @location.listings.first
                end

                should 'create the right amount of listings' do
                  assert_equal 3, @location.listings.count
                end

                should 'have right opening hours that differ from location' do
                  @listing.availability_rules.each do |ar|
                    assert_equal 9, ar.open_hour
                    assert_equal 00, ar.open_minute
                    assert_equal 17, ar.close_hour
                    assert_equal 0, ar.close_minute
                  end
                end

                should 'have the right details' do
                  assert_equal 'Day Office #858', @listing.name
                  assert_equal '', @listing.description
                  assert_equal 3, @listing.quantity
                  assert_equal 4000, @listing.hourly_price_cents
                  assert_equal 28000, @listing.daily_price_cents
                end

                should 'have the right listing type' do
                  assert_equal 'Office Space', @listing.listing_type.name
                end

              end

            end

            context '#location_types' do

              should 'assign the right location type' do
                assert_equal ['Business'], @instance.locations.map { |location| location.location_type.name }.uniq
              end

            end

          end

          context '#location availability_rules' do

            should 'create the right number of availability rules' do
              assert_equal @instance.locations.count*5, @instance.locations.inject(0) { |sum, location| sum += location.availability_rules.count}
            end

          end

          context '#listing availability_rules' do

            should 'create the right amount of availability rules' do
              assert_equal @instance.listings.count*5, @instance.listings.inject(0) { |sum, listing| sum += listing.availability_rules.count}
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
    { :instance => Instance.count, 
      :user => User.count, 
      :company => Company.count, 
      :company_industries => CompanyIndustry.count, 
      :location => Location.count, 
      :location_availability_rules => AvailabilityRule.where(:target_type => 'Location').count, 
      :listing_availability_rules => AvailabilityRule.where(:target_type => 'Listing').count, 
      :location_amenities => LocationAmenity.count, 
      :listing => Listing.count
    }
  end
end
