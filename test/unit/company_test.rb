require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  test "it exists" do
    assert Company
  end

  test "it has a creator" do
    @company = Company.new
    @company.creator = User.new

    assert @company.creator
  end

  test "it has locations" do
    @company = Company.new
    @company.locations << Location.new
    @company.locations << Location.new
    @company.locations << Location.new

    assert @company.locations
  end
end
