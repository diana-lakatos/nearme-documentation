require 'test_helper'

class AfterSignupMailerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  test "help offer works ok" do
    mail = AfterSignupMailer.help_offer(@user)

    assert mail.html_part.body.include?(@name)
    assert_equal ["micheller@desksnear.me"], mail.from
    assert mail.html_part.body.include?("I'm Michelle, co-founder of Desks Near Me.")
  end

  test "offer help with listing" do
    mail = AfterSignupMailer.help_offer(@user)
    assert mail.html_part.body.include?("if you need any help listing or booking a space")
  end

  test "offer help with anything if listing created" do
    @listing = FactoryGirl.create(:listing, :creator => @user)
    
    mail = AfterSignupMailer.help_offer(@user)
    assert mail.html_part.body.include?("I notice you added a new listing")
  end

end
