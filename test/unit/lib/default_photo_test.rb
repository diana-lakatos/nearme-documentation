# frozen_string_literal: true
require 'test_helper'

class DefaultPhotoTest < ActiveSupport::TestCase
  setup do
    @default_photo = DefaultPhoto.new
  end

  context 'without override' do
    should 'find proper url for valid version and klass uploader' do
      PhotoUploader.expects(:default_placeholder).with(:thumb).once
      @default_photo.url(version: :thumb, uploader_klass: PhotoUploader)
    end
  end

  context 'with override' do
    setup do
      @version = :custom
      @uploader_klass = stub
      @image_url = 'http://example.com/image.jpg'
      @image_stub = mock.tap { |m| m.stubs(:url).with(@version).returns(@image_url) }
      @default_photo.stubs(:default_image)
                    .with(version: @version, uploader_klass: @uploader_klass)
                    .returns(OpenStruct.new(photo_uploader_image: @image_stub))
    end

    should 'return proper url if version exists' do
      assert_equal @image_url,
                   @default_photo.url(version: @version, uploader_klass: @uploader_klass)
    end
  end
end
