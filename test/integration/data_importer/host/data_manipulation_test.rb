require 'test_helper'
require 'helpers/gmaps_fake'

class DataImporter::Host::DataManipulationTest < ActiveSupport::TestCase

  def setup
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @location_type = FactoryGirl.create(:location_type, name: 'My Type')
    @transactable_type = FactoryGirl.create(:transactable_type_current_data)
    GmapsFake.stub_requests

    @category1 = FactoryGirl.create(:category)
    @category2 = FactoryGirl.create(:category)
    @category1.update_column(:permalink, 'category1_permalink')
    @category2.update_column(:permalink, 'category2_permalink')

    stub_mixpanel
  end

  context 'current data' do

    should 'not skip empty location and include multiple photos' do
      setup_current_data
      setup_data_for_other_user
      assert_equal (File.open(Rails.root.join('test', 'assets', 'data_importer', 'current_data.csv'), "r") { |io| io.read}), DataImporter::Host::CsvCurrentDataGenerator.new(@user, @transactable_type).generate_csv
    end

    should 'generate proper current data for custom fields' do
      @transactable_type.update_attribute(:custom_csv_fields, [
        {'transactable' => 'my_attribute'},
        {'location' => 'email'},
        {'address' => 'city'},
        {'location' => 'external_id'},
        {'address' => 'street'} ,
        {'photo' => 'image_original_url'},
        {'transactable' => 'external_id'},
        {'location' => 'description'}
      ])
      setup_current_data
      setup_data_for_other_user
      assert_equal (File.open(Rails.root.join('test', 'assets', 'data_importer', 'current_data_custom_fields.csv'), "r") { |io| io.read}), DataImporter::Host::CsvCurrentDataGenerator.new(@user, @transactable_type).generate_csv
    end

  end

  should 'should not raise exception for blank file' do
    setup_current_data
    setup_data_for_other_user
    setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data_blank.csv'), true)
    assert_no_difference 'Company.count' do
      assert_no_difference 'Location.count' do
        assert_no_difference 'Address.count' do
          assert_no_difference 'Transactable.count' do
            assert_no_difference 'Photo.count' do

              DataUploadHostConvertJob.perform(@data_upload.id)
              assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
            end
          end
        end
      end
    end
  end

  should 'should not remove anything after uploading current_data csv' do
    setup_current_data
    setup_data_for_other_user
    setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data.csv'), true)
    assert_no_difference 'Company.count' do
      assert_no_difference 'Location.count' do
        assert_no_difference 'Address.count' do
          assert_no_difference 'Transactable.count' do
            assert_no_difference 'Photo.count' do
              DataUploadHostConvertJob.perform(@data_upload.id)
              assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
            end
          end
        end
      end
    end
  end

  should 'existing listings should have categories after import of modified data with categories' do
    setup_current_data

    setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data_with_categories.csv'), true)
    assert_no_difference 'Company.count' do
      assert_no_difference 'Location.count' do
        assert_no_difference 'Address.count' do
          assert_no_difference 'Transactable.count' do
            assert_no_difference 'Photo.count' do
              DataUploadHostConvertJob.perform(@data_upload.id)
              assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"

              assert_equal [@category1.id, @category2.id], @listing_one.categories.map(&:id).sort
              assert_equal [@category1.id, @category2.id], @listing_two.categories.map(&:id).sort
            end
          end
        end
      end
    end
  end

  should 'existing listings should have their categories overwritten after import of modified data with categories' do
    setup_current_data

    # We setup two categories for each listing
    @listing_one.categories = [@category1, @category2]
    @listing_two.categories = [@category1, @category2]

    # We reload to ensure the categories are in the DB
    @listing_one.reload
    @listing_two.reload

    assert_equal [@category1.id, @category2.id], @listing_one.categories.map(&:id).sort
    assert_equal [@category1.id, @category2.id], @listing_two.categories.map(&:id).sort

    # After upload, they should no longer have two categories each, but only one
    setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data_with_single_categories.csv'), true)
    assert_no_difference 'Company.count' do
      assert_no_difference 'Location.count' do
        assert_no_difference 'Address.count' do
          assert_no_difference 'Transactable.count' do
            assert_no_difference 'Photo.count' do
              DataUploadHostConvertJob.perform(@data_upload.id)
              assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"

              @listing_one.reload
              @listing_two.reload

              assert_equal [@category1.id], @listing_one.categories.map(&:id).sort
              assert_equal [@category1.id], @listing_two.categories.map(&:id).sort
            end
          end
        end
      end
    end
  end

  should 'should be able to parse CSV without external ids' do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    assert_nothing_raised do
      setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data_without_external_ids.csv'), true)
      DataUploadHostConvertJob.perform(@data_upload.id)
      assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
    end
    assert_equal 1, Location.with_deleted.count
    assert_equal 0, Transactable.with_deleted.count
    assert_equal 0, Photo.count
  end

  should 'should be able to restore location instead of creating new one' do
    setup_current_data
    setup_data_for_other_user
    @listing_to_not_be_reverted = FactoryGirl.create(:transactable, location: @location_empty, name: 'my name2', properties: { my_attribute: 'attribute'})
    @listing_to_not_be_reverted.destroy
    assert_no_difference 'Location.count' do
      @location_empty.destroy
      setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data.csv'), true)
      DataUploadHostConvertJob.perform(@data_upload.id)
      assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
    end
    refute @location_empty.reload.deleted?
    assert @listing_to_not_be_reverted.reload.deleted?
  end

  should 'should be able to restore listing instead of creating new one' do
    setup_current_data
    setup_data_for_other_user
    @photo_to_not_be_reverted = FactoryGirl.create(:photo, owner: @listing_one)
    @photo_to_not_be_reverted.destroy
    assert_no_difference 'Transactable.count' do
      @listing_one.destroy
      setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data.csv'), true)
      DataUploadHostConvertJob.perform(@data_upload.id)
    end
    assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
    refute @listing_one.reload.deleted?
    assert @photo_to_not_be_reverted.reload.deleted?
  end

  should 'should just insert new things and update existing ones, without deleting old ones if sync mode disabled' do
    setup_current_data
    setup_data_for_other_user
    setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data_modified.csv'))
    DataUploadHostConvertJob.perform(@data_upload.id)
    assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
    refute @photo_one.reload.deleted?
    assert_equal 3, @listing_one.reload.photos.count
    assert_equal ['http://www.example.com/image1.jpg', 'http://www.example.com/image2.jpg', 'http://www.example.com/image3.jpg'], @listing_one.photos.map(&:image_original_url).sort
    refute @location_empty.reload.deleted?
    assert_equal 'desc2', @location_not_empty.reload.description
    assert_equal 'Aleja Niepodległości 40, Czestochowa, Poland', @location_not_empty.address
    assert_equal 'my updated name', @listing_one.reload.name
    assert_equal 4400, @listing_one.reload.weekly_price_cents
    @new_listing = @user.listings.find_by_external_id('no-touch')
    assert @new_listing.present?
    assert_equal 'newly added hey', @new_listing.name
    assert_equal ['http://www.example.com/image1.jpg'], @new_listing.photos.map(&:image_original_url)
    assert_equal 'the other', @other_listing_two.reload.name
    assert @new_listing.location.present?
    assert_equal '3', @new_listing.location.external_id
    assert_equal 'new location', @new_listing.location.description
    assert_equal 'Ludwika Rydygiera 8, 01-793 Warsaw, Poland', @new_listing.location.address
    refute @listing_two.deleted?
  end

  should 'should do planned changes after submitting different csv in sync mode' do
    setup_current_data
    setup_data_for_other_user
    setup_data_upload(Rails.root.join('test', 'assets', 'data_importer', 'current_data_modified.csv'), true)
    DataUploadHostConvertJob.perform(@data_upload.id)
    assert @data_upload.reload.encountered_error.blank?, "Unexpected error: #{@data_upload.encountered_error}"
    assert @photo_one.reload.deleted?
    refute @photo_two.reload.deleted?
    assert_equal 2, @listing_one.reload.photos.count
    assert_equal ['http://www.example.com/image2.jpg', 'http://www.example.com/image3.jpg'], @listing_one.photos.map(&:image_original_url).sort
    # we want to be able to delete location via csv
    assert @location_empty.reload.deleted?
    # we want to be able to update location and location's address via csv
    assert_equal 'desc2', @location_not_empty.reload.description
    assert_equal 'Aleja Niepodległości 40, Czestochowa, Poland', @location_not_empty.address
    # we want to be able to update listing's via csv
    assert_equal 'my updated name', @listing_one.reload.name
    assert_equal 4400, @listing_one.reload.weekly_price_cents
    # we do not want to allow user to update other's user listing
    # despite @other_listing_two has the same external_id as new listing
    # csv, we want to create a new listing and leave existing listing in peace
    @new_listing = @user.listings.find_by_external_id('no-touch')
    assert @new_listing.present?
    assert_equal 'newly added hey', @new_listing.name
    assert_equal ['http://www.example.com/image1.jpg'], @new_listing.photos.map(&:image_original_url)
    assert_equal 'the other', @other_listing_two.reload.name
    assert @new_listing.location.present?
    assert_equal '3', @new_listing.location.external_id
    assert_equal 'new location', @new_listing.location.description
    assert_equal 'Ludwika Rydygiera 8, 01-793 Warsaw, Poland', @new_listing.location.address
    assert @listing_two.reload.deleted?
  end

  protected

  def setup_current_data
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @location_not_empty = FactoryGirl.create(:location_rydygiera, name: 'Rydygiera', company: @company, location_type: @location_type, external_id: 2)
    @listing_one = FactoryGirl.create(:transactable, location: @location_not_empty, name: 'my name', properties: { my_attribute: 'attribute' }, daily_price: 89, external_id: 4353)
    stub_image_url('http://www.example.com/image1.jpg')
    stub_image_url('http://www.example.com/image2.jpg')
    stub_image_url('http://www.example.com/image3.jpg')
    @photo_one = FactoryGirl.create(:photo, owner: @listing_one, creator: @user, image_original_url: 'http://www.example.com/image1.jpg')
    @photo_two = FactoryGirl.create(:photo, owner: @listing_one, creator: @user, image_original_url: 'http://www.example.com/image2.jpg')
    @listing_two = FactoryGirl.create(:transactable, location: @location_not_empty, name: 'my name2', properties: { my_attribute: 'attribute' }, daily_price: 89, external_id: 4354)
    @location_empty = FactoryGirl.create(:location_czestochowa, name: 'Czestochowa', company: @company, location_type: @location_type, external_id: 1)
  end

  def setup_data_for_other_user
    @other_user = FactoryGirl.create(:user)
    @other_company = FactoryGirl.create(:company, creator: @other_user)
    @other_location_not_empty = FactoryGirl.create(:location_rydygiera, company: @other_company, location_type: @location_type, external_id: 2)
    @other_listing_one = FactoryGirl.create(:transactable, location: @other_location_not_empty, name: 'my other name', properties: { my_attribute: 'attribute' }, daily_price: 10, external_id: 4353)
    stub_image_url('http://www.example.com/other-image.jpg')
    @other_photo_one = FactoryGirl.create(:photo, owner: @other_listing_one, image_original_url: 'http://www.example.com/other-image.jpg')
    @other_listing_two = FactoryGirl.create(:transactable, location: @other_location_not_empty, name: 'the other', properties: { my_attribute: 'attribute' }, daily_price: 10, external_id: "no-touch")
  end

  def setup_data_upload(csv_path, sync_mode = false)
    @data_upload = FactoryGirl.create(:data_upload, sync_mode: sync_mode, importable: @transactable_type, csv_file: File.open(csv_path), target: @company, uploader: @user)
  end

end

