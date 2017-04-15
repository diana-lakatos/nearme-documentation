# frozen_string_literal: true
require 'test_helper'
require 'graph/schema'

class Graph::Resolvers::UsersTest < ActiveSupport::TestCase
  context 'custom attribute photos' do
    setup { @user = FactoryGirl.create(:user) }

    should 'get photos' do
      args = { name: 'cover_image' }

      images = Graph::Resolvers::Users::CustomAttributePhotos.new.call(@user, args, nil)

      assert_not_nil images
    end

    should 'get photos with custom order' do
      args = { name: 'cover_image', order: :created_at, order_direction: 'ASC' }

      images = Graph::Resolvers::Users::CustomAttributePhotos.new.call(@user, args, nil)

      assert_not_nil images
    end
  end
end
