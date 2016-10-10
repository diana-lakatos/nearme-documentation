require 'test_helper'

class Authentication::InfoUpdaterTest < ActiveSupport::TestCase
  context 'When having an authentication' do
    setup do
      @authentication = FactoryGirl.create(:authentication)
      @user = @authentication.user
    end

    should 'update authentication and its user according to social info' do
      raw = OpenStruct.new(id: 'dnm',
                           username: 'desksnearme',
                           name: 'Desks Near Me',
                           description: Faker::Lorem.paragraph(50),
                           url: 'http://twitter.com/desksnearme')
      raw.stubs(:profile_image_url).returns('http://twitter.com/avatar.jpg')
      stub_request(:get, 'http://twitter.com/avatar.jpg').to_return(status: 200, body: File.read(Rails.root.join('test', 'assets', 'foobear.jpeg')), headers: { 'Content-Type' => 'image/jpeg' })
      Twitter::REST::Client.any_instance.stubs(:user).once.returns(raw)

      Authentication::InfoUpdater.new(@authentication).update

      @user.reload; @authentication.reload
      assert_equal 'http://twitter.com/desksnearme', @authentication.profile_url
      assert_not_equal 'Desks Near Me', @user.name
      assert @user.avatar.to_s.include?('avatar.jpg')
      assert @authentication.information_fetched.present?
    end
  end
end
