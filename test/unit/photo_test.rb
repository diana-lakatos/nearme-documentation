require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  should belong_to(:creator)
  # TODO: why?
  # should validate_presence_of(:image)
  should allow_value(nil).for(:caption)

  context 'metadata' do
    setup do
      stub_image_url('http://www.example.com/image.jpg')
    end

    context 'triggering' do
      should 'not trigger populate metadata on listing if condition fails' do
        @transactable = FactoryGirl.create(:transactable)
        CarrierWave::SourceProcessing::Processor.any_instance.stubs(:enqueue_processing).returns(true)
        Transactable.any_instance.expects(:populate_photos_metadata!).never
        Photo.any_instance.expects(:should_populate_metadata?).returns(false).at_least(1)
        FactoryGirl.create(:photo)
      end

      should 'trigger populate metadata on listing if condition succeeds' do
        Transactable.any_instance.expects(:populate_photos_metadata!).at_least(1)
        Photo.any_instance.expects(:should_populate_metadata?).returns(true).at_least(1)
        FactoryGirl.create(:photo)
      end
    end

    context 'should_populate_metadata?' do
      setup do
        @photo = FactoryGirl.create(:photo)
      end

      should 'return true if new photo is created' do
        assert @photo.should_populate_metadata?
      end

      should 'return false if no listing is defined but true if added' do
        @photo.listing = nil
        @photo.save!
        refute @photo.should_populate_metadata?
        @photo.listing = FactoryGirl.create(:transactable)
        @photo.save!
        assert @photo.should_populate_metadata?
      end

      should 'return true if photo was destroyed' do
        @photo.destroy
        assert @photo.should_populate_metadata?
      end

      should 'return true if caption was changed' do
        @photo.update_attributes(caption: 'caption was changed')
        assert @photo.should_populate_metadata?
      end

      should 'return true if original url was changed' do
        stub_image_url('http://www.example.com/image.jpg')
        @photo.image_original_url = 'http://www.example.com/image.jpg'
        @photo.save!
        assert @photo.should_populate_metadata?
      end

      should 'return false if nothing important was changed' do
        @photo.updated_at = Time.zone.now
        @photo.save!
        refute @photo.should_populate_metadata?
      end
    end
  end
end
