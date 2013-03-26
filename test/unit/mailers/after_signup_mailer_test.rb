require 'test_helper'

class AfterSignupMailerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  test "help offer works ok" do
    mail = AfterSignupMailer.help_offer(@user.id)

    assert mail.html_part.body.include?(@name)
    assert_equal ["micheller@desksnear.me"], mail.from
    assert mail.html_part.body.include?("Welcome to Desks Near Me!")
  end

  test "offer help with listing" do
    mail = AfterSignupMailer.help_offer(@user.id)
    assert mail.html_part.body.include?("I saw that you signed up but haven't added a space for rent.")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

  test "offer help with anything if listing created" do
    @listing = FactoryGirl.create(:listing, :creator => @user)
    mail = AfterSignupMailer.help_offer(@user.id)
    assert mail.html_part.body.include?("Thanks for listing your space")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

end
