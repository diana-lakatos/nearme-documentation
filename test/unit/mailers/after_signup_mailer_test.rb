require 'test_helper'

class AfterSignupMailerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
  end

  test "help offer works ok" do
    mail = AfterSignupMailer.help_offer(@instance, @user.id)

    assert mail.html_part.body.include?(@name)
    assert_equal ["micheller@desksnear.me"], mail.from
    assert mail.html_part.body.include?("Welcome to Desks Near Me!")
  end

  context "version if user booked a listing" do

    setup do
      @reservation = FactoryGirl.create(:reservation, :owner => @user)
    end

    should "use proper template" do
      mail = AfterSignupMailer.help_offer(@instance, @user.id)
      assert mail.html_part.body.include?("and congratulations on your first booked #{@instance.bookable_noun}!")
      assert !mail.html_part.body.include?("The Desks Near Me Team")
    end

  end

  test "version if user added a listing" do
    @listing = FactoryGirl.create(:listing, :creator => @user)
    mail = AfterSignupMailer.help_offer(@instance, @user.id)
    assert mail.html_part.body.include?("Thanks for listing your #{@instance.bookable_noun} with Desks Near Me!")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

  test "version if user neither booked a listing nor added a listing" do
    mail = AfterSignupMailer.help_offer(@instance, @user.id)
    assert mail.html_part.body.include?("I saw that you signed up but haven't added a #{@instance.bookable_noun} for rent")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

end
