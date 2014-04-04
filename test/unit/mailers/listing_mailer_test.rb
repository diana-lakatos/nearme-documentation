require 'test_helper'

class ListingMailerTest < ActiveSupport::TestCase

  setup do
    stub_mixpanel
    @listing = FactoryGirl.create(:transactable)
    @user = FactoryGirl.create(:user)
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
    @platform_context = PlatformContext.current
    @subject = "#{@user.name} has shared a listing with you on #{@platform_context.decorate.name}"
  end

  test "#share" do
    mail = ListingMailer.share(@listing, 'jimmy@test.com', 'Jimmy Falcon', @user, 'Check this out!')

    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?(@user.name)
    assert mail.html_part.body.include?('They also wanted to say:')
    assert mail.html_part.body.include?('Check this out!')
    assert_contains 'href="http://custom.domain.com/', mail.html_part.body
    assert_not_contains 'href="http://example.com', mail.html_part.body
    assert_not_contains 'href="/', mail.html_part.body

    assert_equal ['jimmy@test.com'], mail.to
  end

  test "#share without message" do
    mail = ListingMailer.share(@listing, 'jimmy@test.com', 'Jimmy Falcon', @user)

    assert_equal @subject, mail.subject
    assert mail.html_part.body.include?(@user.name)
    refute mail.html_part.body.include?('They also wanted to say:')

    assert_equal ['jimmy@test.com'], mail.to
  end

end
