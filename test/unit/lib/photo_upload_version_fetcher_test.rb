# frozen_string_literal: true
require 'test_helper'

class PhotoUploadVersionFetcherTest < ActiveSupport::TestCase
  setup do
    @photo_uploader_version_fetcher = PhotoUploadVersionFetcher.new
  end

  context 'without override' do
    should 'find proper dimensions for valid version and klass uploader' do
      assert_equal PhotoUploader.dimensions[:thumb],
                   @photo_uploader_version_fetcher.dimensions(version: :thumb, uploader_klass: PhotoUploader)
    end

    should 'return default if no version' do
      assert_equal PhotoUploadVersionFetcher::DEFAULT_DIMENSIONS,
                   @photo_uploader_version_fetcher.dimensions(version: nil, uploader_klass: PhotoUploader)
    end

    should 'return default if no uploader klass' do
      assert_equal PhotoUploadVersionFetcher::DEFAULT_DIMENSIONS,
                   @photo_uploader_version_fetcher.dimensions(version: :thumb, uploader_klass: nil)
    end
  end

  context 'with override' do
    setup do
      @version = :custom
      @uploader_klass = stub
      @photo_uploader_version_fetcher.stubs(:photo_uploader_version)
                                     .with(version: @version, uploader_klass: @uploader_klass)
                                     .returns(OpenStruct.new(apply_transform: 'fit_to_resize',
                                                             width: 10,
                                                             height: 50))
    end

    should 'return proper dimensions if version exists' do
      assert_equal({ transform: 'fit_to_resize', width: 10, height: 50 },
                   @photo_uploader_version_fetcher.dimensions(version: @version, uploader_klass: @uploader_klass))
    end
  end
end
