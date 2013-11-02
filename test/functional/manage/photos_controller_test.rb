require 'test_helper'

class Manage::PhotosControllerTest < ActionController::TestCase
  context 'update with crop and rotate' do
    setup do
      @listing = FactoryGirl.create(:listing, photos_count: 1)
      @photo   = @listing.photos.first
      @user    = @listing.company.creator

      @user.stubs(:photos => stub(:find => @photo))
      Manage::PhotosController.any_instance.stubs(:current_user).returns(@user)
      @photo.expects(:save).once.returns(true)

      sign_in(@user)
    end

    should 'set transformation data for crop and save' do
      @photo.expects(:image_transformation_data=).once.with(crop: { 'w' => '1', 'h' => '2', 'x' => '10', 'y' => '20' }, rotate: nil)

      put :update, id: @photo.id, crop: { 'w' => 1, 'h' => 2, 'x' => 10, 'y' => 20 }
    end

    should 'set transformation data for rotate and save' do
      @photo.expects(:image_transformation_data=).once.with(crop: nil, rotate: '90')

      put :update, id: @photo.id, rotate: '90'
    end
  end
end
