require 'test_helper'

class DocumentRequirementTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:item)

  should validate_presence_of(:label)
  should validate_presence_of(:description)
  should validate_presence_of(:item)
end
