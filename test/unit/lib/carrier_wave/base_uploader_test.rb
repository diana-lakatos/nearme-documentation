# frozen_string_literal: true
require 'test_helper'
require Rails.root.join 'test/helpers/placeholder_helper'
include PlaceholderHelper

class MountUploaderTest < ActiveSupport::TestCase
  include PlaceholderHelper

  context '#url' do
    setup do
      CarrierWave::SourceProcessing::Processor.any_instance.stubs(:enqueue_processing).returns(true)
      @photo = FactoryGirl.create(:photo, image_versions_generated_at: nil)
    end

    context 'original' do
      should 'return proper url' do
        assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.url)
      end
    end

    should 'return proper url for immediate versions' do
      assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.url(:medium))
    end

    should 'return proper url for delayed versions after generation' do
      assert_equal placeholder_url(895, 554), @photo.image.url(:golden)
      CarrierWave::SourceProcessing::Processor.new(@photo, :image).generate_versions
      assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.url(:golden))
    end
  end

  context '#default_url' do
    should 'return transformed version versions dimensions if they are provided' do
      photo = FactoryGirl.create(:photo, image_versions_generated_at: nil)
      assert_equal placeholder_url(895, 554), photo.image.default_url(:golden)
    end

    should 'return default 100x100 placeholder for original version' do
      page = FactoryGirl.create(:page)
      assert_equal placeholder_url(100, 100), page.hero_image.default_url
    end
  end
end
