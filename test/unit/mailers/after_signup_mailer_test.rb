require 'test_helper'
 
class AfterSignupMailerTest < ActiveSupport::TestCase

  setup do
    @subject = "Welcome to DesksNear.me"
    @user = FactoryGirl.create(:user)
    @platform_context = PlatformContext.new
    @from = @platform_context.decorate.contact_email
  end

  test "help offer works ok" do
    mail = AfterSignupMailer.help_offer(@platform_context, @user)

    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?(@user.name)
    assert_equal ["micheller@desksnear.me"], mail.from
    assert mail.html_part.body.include?("Welcome to Desks Near Me!")
  end

  context "version if user booked a listing" do

    setup do
      @reservation = FactoryGirl.create(:reservation, :owner => @user)
    end

    should "use proper template" do
      mail = AfterSignupMailer.help_offer(@platform_context, @user)
      assert mail.html_part.body.include?("and congratulations on your first booked #{@platform_context.decorate.bookable_noun}!"), "and congratulations on your first booked #{@platform_context.decorate.bookable_noun}! was not found in\n#{mail.html_part.body}"
      assert !mail.html_part.body.include?("The Desks Near Me Team")
    end

  end

  test "version if user added a listing" do
    @listing = FactoryGirl.create(:listing)
    @user = @listing.creator
    mail = AfterSignupMailer.help_offer(@platform_context, @user)
    assert mail.html_part.body.include?("Thanks for listing your #{@platform_context.decorate.bookable_noun} with Desks Near Me!")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

  test "version if user neither booked a listing nor added a listing" do
    mail = AfterSignupMailer.help_offer(@platform_context, @user)
    assert mail.html_part.body.include?("I saw that you signed up but haven't added a #{@platform_context.decorate.bookable_noun} for rent")
    assert !mail.html_part.body.include?("The Desks Near Me Team")
  end

end
