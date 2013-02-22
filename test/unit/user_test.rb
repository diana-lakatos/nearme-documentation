require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should have_many(:industries)

  test "it exists" do
    assert User
  end

  test "it has authentications" do
    @user = User.new
    @user.authentications << Authentication.new
    @user.authentications << Authentication.new

    assert @user.authentications
  end

  test "it knows what authentication providers it is linked to" do
    @user = User.find(16)
    @user.authentications.find_or_create_by_provider("exists").tap do |a|
      a.uid = 16
    end.save!
    assert @user.linked_to?("exists")
  end

  test "it knows what authentication providers it isn't linked to" do
    @user = User.find(16)
    refute @user.linked_to?("doesntexist")
  end

  test "it has reservations" do
    @user = User.new
    @user.reservations << Reservation.new
    @user.reservations << Reservation.new

    assert @user.reservations
  end

  test "users have full email addresses" do
    @user = User.new(name: "Hulk Hogan", email: "hulk@desksnear.me")

    assert_equal "Hulk Hogan <hulk@desksnear.me>", @user.full_email
  end

  test "avatar not uploaded if user did not upload it" do
    @user = FactoryGirl.create(:user)
    assert_equal false, @user.avatar_provided?
  end

  test "avatar is uploaded if user uploaded it" do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path("../../assets/foobear.jpeg", __FILE__))
    @user.save!
    assert @user.avatar_provided?
  end

  test "image without extension does not prevent from saving user" do
    @user = FactoryGirl.build(:user)
    @user.avatar = File.open(File.expand_path("../../assets/image_no_extension", __FILE__))
    @user.save!
    assert @user.avatar_provided?
  end

  test "image uploaded via remote url is uploaded after save" do
    stub_image_url("http://www.example.com/image.jpg")
    @user = FactoryGirl.create(:user)
    @user.remote_avatar_url = "http://www.example.com/image.jpg"
    begin
      @user.save!
    rescue
    end
    assert @user.avatar_provided?
  end

  test "image uploaded via remote url is not uploaded before save" do
    stub_image_url("http://www.example.com/image.jpg")
    @user = FactoryGirl.create(:user)
    @user.remote_avatar_url = "http://www.example.com/image.jpg"
    @user.reload
    assert @user.avatar_provided?
  end

end
