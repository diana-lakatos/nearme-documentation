require 'test_helper'
require 'rails/performance_test_help'

class HomepageTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  context 'not logged in' do

    should 'test homepage' do
      get '/'
    end

  end

  context 'logged in user' do

    setup do
      FactoryGirl.create(:user, :email => 'user@example.com', :password => 'password', :password_confirmation => 'password')
      post '/sessions', { :email => 'user@example.com', :password => 'password' }
    end

    should 'test homepage' do
      get '/'
    end

  end

end
