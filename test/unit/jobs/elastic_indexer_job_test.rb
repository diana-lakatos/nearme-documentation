require 'test_helper'

class CreateElbJobTest < ActiveSupport::TestCase
  context '#perform' do
    setup do
      @user = FactoryGirl.create(:user)
    end

    should 'not crash when elastic disabled' do
      refute ElasticIndexerJob.perform('index', 'User', @user.id)
    end

    should 'index when elastic enabled' do
      enable_elasticsearch!

      assert ElasticIndexerJob.perform('index', 'User', @user.id)

      disable_elasticsearch!
    end

    should 'delete when elastic enabled' do
      enable_elasticsearch!
      ElasticIndexerJob.perform('index', 'User', @user.id)

      assert ElasticIndexerJob.perform('delete', 'User', @user.id)

      disable_elasticsearch!
    end
  end
end
