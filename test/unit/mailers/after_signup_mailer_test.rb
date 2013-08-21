require 'test_helper'

class AfterSignupMailerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @subject = "Test subject"
    @from = "micheller@desksnear.me"

    details = {
      from: @from,
      subject: @subject
    }
    PrepareEmail.for('after_signup_mailer/user_with_listing', details)
    PrepareEmail.for('after_signup_mailer/user_without_listing_and_booking', details)
    PrepareEmail.for('after_signup_mailer/user_with_booking', details)
    PrepareEmail.for('layouts/mailer')
  end

  test "help offer works ok" do
    mail = AfterSignupMailer.help_offer(@user.id)

    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?(@name)
    assert_equal [@from], mail.from
    assert mail.html_part.body.include?("Welcome to Desks Near Me!")
  end

  context "version if user booked a listing" do

    setup do
      @reservation = FactoryGirl.create(:reservation, :owner => @user)
    end

    should "use proper template" do
      mail = AfterSignupMailer.help_offer(@user.id)
      assert mail.html_part.body.include?("and congratulations on your first booked #{@user.instance.bookable_noun}!")
      assert !mail.html_part.body.include?("The Desks Near Me Team")
    end

  end

  test "version if user added a listing" do
    @listing = FactoryGirl.create(:listing, :creator => @user)
    mail = AfterSignupMailer.help_offer(@user.id)
    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?("Thanks for listing your #{@user.instance.bookable_noun} with Desks Near Me!")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

  test "version if user neither booked a listing nor added a listing" do
    mail = AfterSignupMailer.help_offer(@user.id)
    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?("I saw that you signed up but haven't added a #{@user.instance.bookable_noun} for rent")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

end
