require 'test_helper'

class AfterSignupMailerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  test "help offer works ok" do
    mail = AfterSignupMailer.help_offer(@user)

    assert mail.html_part.body.include?(@name)
    assert_equal ["michelle@desksnear.me"], mail.from
    assert mail.html_part.body.include?("I'm Michelle, co-founder of Desks Near Me.")
  end

end
