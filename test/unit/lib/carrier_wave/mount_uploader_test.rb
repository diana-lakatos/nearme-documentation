require 'test_helper'

class MountUploaderTest < ActiveSupport::TestCase
  should 'assign dimensions' do
    photo = FactoryGirl.create(:photo)
    assert_not_nil(photo.image_original_width)
    assert_not_nil(photo.image_original_height)
  end

  should 'reassign dimensions on attachment update' do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
    @user.save!
    width = @user.avatar_original_width
    height = @user.avatar_original_height
    @user.avatar = File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
    @user.save!
    assert_not_equal(width, @user.avatar_original_width)
    assert_not_equal(height, @user.avatar_original_height)
  end

  should 'remove metadata if avatar removed' do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
    @user.save!
    assert @user.avatar.file.present?
    assert_not_nil @user.avatar_original_width
    assert_not_nil @user.avatar_original_height
    @user.avatar = nil
    @user.save!
    %w(versions_generated_at transformation_data original_width original_height).each do |attr|
      assert_nil @user.attributes[attr]
    end
  end

  should 'process delayed_versions in the background if uploader responds to delayed_versions' do
    photo = FactoryGirl.build(:photo)
    VersionRegenerationJob.expects(:perform).with(Photo, photo.save! && photo.id, :image, false)
  end

  should 'not process all versions on initial save if uploader responds to delayed_versions' do
    photo = FactoryGirl.build(:photo)
    VersionRegenerationJob.expects(:perform).once
    photo.save!
  end

  should 'only set timestamp if uploader does not respond to delayed_versions' do
    theme = FactoryGirl.build(:theme_with_logo_image)
    VersionRegenerationJob.expects(:perform).never
    theme.save!
    assert_not_nil(theme.logo_image_versions_generated_at)
  end

  should 'recreate all versions if transformation data is changed' do
    photo = FactoryGirl.create(:photo)
    photo.image_transformation_data = { rotate: 180 }
    VersionRegenerationJob.expects(:perform).with(Photo, photo.save! && photo.id, :image, true).once
  end
end
