require 'test_helper'

class CarrierWave::InkFilePickerTest < ActiveSupport::TestCase

  context '#avatar' do

    setup do
      @user = FactoryGirl.create(:user)
      stub_image_url('http://www.example.com/image.jpg')
    end

    context 'without carrierwave avatar' do

      context 'with inkfilepicker url' do

        setup do
          @user.avatar_original_url = 'http://www.example.com/image.jpg'
        end

        should 'know that carrierwave does not exists' do
          assert !@user.avatar.exists?
        end

        should 'be able to display avatar' do
          assert_equal @user.avatar_original_url, @user.avatar_url
        end

        should 'be able to display thumbnail' do
          assert_equal @user.avatar_original_url + "/convert?fit=crop&h=144&w=144", @user.avatar_url(:medium)
        end

        should 'know that avatar exists' do
          assert @user.avatar.any_url_exists?
        end

      end

      context 'without inkfilepicker url' do

        should 'not have avatar url' do
          assert_nil @user.avatar_url
        end

        should 'know that avatar does not exist' do
          assert !@user.avatar.any_url_exists?
        end

      end
    end

    context 'with carrierwave avatar' do

      context 'with inkfilepicker url' do

        setup do
          @user.avatar_original_url = 'http://www.example.com/image.jpg'
          @user.avatar = File.open(File.expand_path("../../../assets/foobear.jpeg", __FILE__))
          @user.save!
          # setting original url should reset avatar_versions_generated, that's why we set it here
          @user.avatar_versions_generated_at = Time.zone.now
          @user.save!
        end

        should 'know that carrierwave exists' do
          @user.avatar.exists?
        end

        should 'be able to display avatar' do
          assert_equal @user.avatar.url, @user.avatar_url
        end

        should 'be able to display avatar thumbnail' do
          assert_equal @user.avatar.url(:medium), @user.avatar_url(:medium)
        end

        should 'know that avatar exists' do
          assert @user.avatar.any_url_exists?
        end

        context 'versions not generated' do
          setup do
            @user.avatar_versions_generated_at = nil
            @user.save!
          end

          should 'know that avatar exists ' do
            assert @user.avatar.any_url_exists?
          end

          should 'be able to display avatar' do
            assert_equal @user.avatar_original_url, @user.avatar_url
          end

          should 'be able to display thumbnail' do
            assert_equal @user.avatar_original_url + "/convert?fit=crop&h=144&w=144", @user.avatar_url(:medium)
          end

          should 'know that avatar is ready to be displayed' do
            assert @user.avatar.any_url_ready?
          end

        end
      end

      context 'without inkfilepicker url' do

        setup do
          @user.avatar = File.open(File.expand_path("../../../assets/foobear.jpeg", __FILE__))
          @user.avatar_versions_generated_at = Time.zone.now
          @user.save!
        end

        should 'know that carrierwave exists' do
          assert @user.avatar.exists?
        end

        should 'be able to display avatar' do
          assert_equal @user.avatar.url, @user.avatar_url
        end

        should 'be able to display avatar thumbnail' do
          assert_equal @user.avatar.url(:medium), @user.avatar_url(:medium)
        end

        should 'know that avatar exists' do
          assert @user.avatar.any_url_exists?
        end

        should 'know that avatar is ready to be shown' do
          assert @user.avatar.any_url_ready?
        end
      end

    end
  end

  context '#photo' do

    should 'respond to image_original_url ' do
      @photo = FactoryGirl.create(:photo, :image_original_url => 'http://www.example.com/image.jpg')
      assert @photo.image.url(:medium), @photo.image_url(:medium)
    end

    should 'be able to display thumbnail immediately' do
      @photo = FactoryGirl.create(:photo, :image_original_url => 'http://www.example.com/image.jpg', :image => nil)
      assert_equal @photo.image_original_url + "/convert?fit=crop&h=89&w=144", @photo.image_url(:medium)

    end
  end

end
