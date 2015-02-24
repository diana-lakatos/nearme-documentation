require 'test_helper'

class Attachable::AttachmentTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:user)
  should belong_to(:attachable)
end
