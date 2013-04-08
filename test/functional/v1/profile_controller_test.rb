require 'test_helper'

class V1::ProfileControllerTest < ActionController::TestCase

  setup do
    @user = users(:one)
    @user.ensure_authentication_token!
    @request.env['Authorization'] = @user.authentication_token
  end

  test "should show profile" do
    get :show
    assert_response :success
  end

  context "#update" do
    should "update profile" do
      raw_put :update, {:id => users(:one).id}, '{"name": "Alvina Q. DuBuque"}'
      assert_response :success

      @user.reload
      assert_equal "Alvina Q. DuBuque", @user.name
    end

    should "not raise when no name is included" do
      assert_nothing_raised do
        raw_put :update, {:id => users(:one).id}, '{"phone": "1 234 56890"}'
      end
    end

    should "update phone" do
      raw_put :update, {:id => users(:one).id}, '{ "name": "John Doe", "phone": "+1 (800) 555-1234"}'
      assert_response :success

      @user.reload
      assert_equal "+1 (800) 555-1234", @user.phone
    end
  end


  test "should add avatar image to current user object when data of content type image/jpeg is posted to the method" do
    raw_post :upload_avatar, {:filename => "avatar.jpg"}, IO.read('test/fixtures/listing.jpg')
    assert_response :success
  end

  test "should fail when data of content type other than image/jpeg is posted to the method" do
    raw_post :upload_avatar, {:filename => "avatar.jpg"}, IO.read('test/fixtures/avatar.txt')
    assert_response :unprocessable_entity
  end

  test "should remove avatar image and clear column" do
    @user.avatar.store!(File.open("test/fixtures/avatar.jpg"))
    @user.save!
    assert_not_nil @user.avatar

    delete :destroy_avatar

    json = JSON.parse(response.body)
    assert json
    assert_blank json["avatar"]
  end

  test "not raising error when removing not existing avatar" do
    delete :destroy_avatar

    json = JSON.parse(response.body)
    assert json
    assert_blank json["avatar"]
  end

end
