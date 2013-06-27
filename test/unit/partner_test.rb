require 'test_helper'

class PartnerTest < ActiveSupport::TestCase
  context "should" do
    should have_many(:instances)
  end
end
