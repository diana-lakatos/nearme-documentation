# frozen_string_literal: true
require 'test_helper'

class PhotoUploadVersionTest < ActiveSupport::TestCase
  context 'photo upload versions' do
    should 'test resize of photos' do
      PhotoUploader.enable_processing = true
      photo = FactoryGirl.create(:photo, image_versions_generated_at: nil)
      assert_equal 410, MiniMagick::Image.open(File.join(Rails.root, 'public', photo.image.url(:space_listing)))[:width]

      puv = PhotoUploadVersion.new
      puv.theme = PlatformContext.current.theme
      puv.apply_transform = 'resize_to_fill'
      puv.width = 313
      puv.height = 296
      puv.photo_uploader = 'PhotoUploader'
      puv.version_name = 'space_listing'
      puv.save!
      PlatformContext.current.instance_variable_set(:'@photo_upload_versions_fetcher', nil)

      RegenerateUploaderVersionsJob.perform('PhotoUploader')

      assert_equal 313, MiniMagick::Image.open(File.join(Rails.root, 'public', photo.image.url(:space_listing)))[:width]

      PhotoUploader.enable_processing = false
    end
  end
end
