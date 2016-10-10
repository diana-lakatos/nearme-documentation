require 'test_helper'

class VersionRegenerationJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'call generate versions' do
      photo = FactoryGirl.create(:photo)
      CarrierWave::SourceProcessing::Processor.any_instance.expects(:generate_versions).once
      VersionRegenerationJob.perform('Photo', photo.id, :image, true)
    end

    should 'repopulate photos metadata if object is a photo and it has listing' do
      photo = FactoryGirl.create(:photo)
      Photo.any_instance.expects(:listing_populate_photos_metadata!).once
      VersionRegenerationJob.perform('Photo', photo.id, :image, true)
    end

    should 'not populate metadata if object is a photo and it has no listings' do
      photo = FactoryGirl.create(:photo, listing: nil)
      Photo.any_instance.expects(:listing_populate_photos_metadata!).never
      VersionRegenerationJob.perform('Photo', photo.id, :image, true)
    end

    should 'not try to populate metadata if object is not a photo' do
      user = FactoryGirl.create(:demo_user)
      User.any_instance.expects(:listing_populate_photos_metadata!).never
      VersionRegenerationJob.perform('User', user.id, :avatar, true)
    end
  end
end
