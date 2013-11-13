require 'test_helper'

class UserRelationshipTest < ActiveSupport::TestCase
  should belong_to(:follower)
  should belong_to(:followed)
end
