require 'test_helper'

class PlatformMailerTest < ActiveSupport::TestCase

  test "contact request mailer works" do
    platform_contact = FactoryGirl.create(:platform_contact)
    mail = PlatformMailer.contact_request(platform_contact)

    assert mail.body.include?(platform_contact.name)
    assert mail.body.include?(platform_contact.company)
    assert mail.body.include?(platform_contact.email)
    assert mail.body.include?(platform_contact.phone)
    assert mail.body.include?(platform_contact.comments)
  end
end
