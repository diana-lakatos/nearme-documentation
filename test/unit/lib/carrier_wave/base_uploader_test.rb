require 'test_helper'

class MountUploaderTest < ActiveSupport::TestCase
  context '#url' do
    setup do
      CarrierWave::SourceProcessing::Processor.any_instance.stubs(:enqueue_processing).with(false).returns(true)
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
      assert_match /\/\/placehold.it\/895x554(.+)/, @photo.image.url(:golden)
      CarrierWave::SourceProcessing::Processor.new(@photo, :image).generate_versions
      assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.url(:golden))
    end
  end

  context '#default_url' do
    should 'return transformed version versions dimensions if they are provided' do
      photo = FactoryGirl.create(:photo, image_versions_generated_at: nil)
      assert_equal '895x554&text=Photos+Unavailable+or+Still+Processing', photo.image.default_url(:golden).split('/').last
    end

    should 'return default 100x100 placeholder for original version' do
      page = FactoryGirl.create(:page)
      assert_equal '100x100&text=Photos+Unavailable+or+Still+Processing', page.hero_image.default_url.split('/').last
    end
  end
end
