require 'test_helper'

class UserTest < ActiveSupport::TestCase
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
end
