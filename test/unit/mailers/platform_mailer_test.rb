require 'test_helper'

class PlatformMailerTest < ActiveSupport::TestCase

  test "contact request mailer works" do
    platform_contact = FactoryGirl.create(:platform_contact)
    mail = PlatformMailer.contact_request(platform_contact)

    assert mail.body.include?(platform_contact.name)
    assert mail.body.include?(platform_contact.email)
    assert mail.body.include?(platform_contact.subject)
    assert mail.body.include?(platform_contact.comments)
  end

  test "demo request mailer works" do
    platform_demo_request = FactoryGirl.create(:platform_demo_request)
    mail = PlatformMailer.demo_request(platform_demo_request)

    assert mail.body.include?(platform_demo_request.name)
    assert mail.body.include?(platform_demo_request.email)
    assert mail.body.include?(platform_demo_request.company)
    assert mail.body.include?(platform_demo_request.phone)
    assert mail.body.include?(platform_demo_request.comments)
  end
end
