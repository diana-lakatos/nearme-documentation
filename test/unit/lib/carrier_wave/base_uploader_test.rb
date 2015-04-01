require 'test_helper'

class MountUploaderTest < ActiveSupport::TestCase

  context '#current_url' do
    setup do
      CarrierWave::SourceProcessing::Processor.any_instance.stubs(:enqueue_processing).with(false).returns(true)
      @photo = FactoryGirl.create(:photo, image_versions_generated_at: nil)
    end

    context 'original' do
      should 'return proper url' do
        assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.current_url)
      end
    end

    context 'immediate versions' do
      should 'return proper url' do
        assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.current_url(:medium))
      end
    end

    context 'delayed versions' do

      should 'return proper url if version already generated' do
        assert_match(/placeholder/, @photo.image.current_url(:thumb))
        assert_match(/placeholder/, Photo.find(@photo.id).image.current_url(:thumb))
        CarrierWave::SourceProcessing::Processor.new(@photo, :image).generate_versions(false)
        assert_match(/instances\/1\/uploads\/images\/photo\/image/, @photo.image.current_url(:thumb))
      end


      context 'version not yet generated' do
        should 'return source url if it is present' do
          stub_image_url('http://some.cool.img/image.jpg')
          @photo = FactoryGirl.create(:photo,
            image_original_url: 'http://some.cool.img/image.jpg',
            image_versions_generated_at: nil
          )
          assert_match(/http:\/\/some.cool.img\/image.jpg/, @photo.image.current_url(:thumb))
        end

        should 'return placeholder url if there is no source_url' do
          assert_match(/placeholders/, @photo.image.current_url(:thumb))
        end
      end
    end

  end

  context '#default_url' do
    should 'return placeholder with versions dimensions if they are provided' do
      photo = FactoryGirl.create(:photo, image_versions_generated_at: nil)
      assert_equal '895x554.gif', photo.image.current_url(:golden).split('/').last
    end

    should 'return default 100x100 placeholder for original version' do
      page = FactoryGirl.create(:page)
      assert_equal '100x100.gif', page.hero_image.current_url.split('/').last
    end

    should 'return default 100x100 placeholder if dimensions are not provided' do
      page = FactoryGirl.create(:page)
      assert_equal '100x100.gif', page.hero_image.current_url.split('/').last
    end
  end

end
