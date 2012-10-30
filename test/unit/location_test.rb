require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  should belong_to(:creator)
  should belong_to(:company)
  should have_many(:listings)

  should validate_presence_of(:company_id)
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_presence_of(:address)
  should validate_presence_of(:latitude)
  should validate_presence_of(:longitude)
  should_not allow_value('not_an_email').for(:email)
  should allow_value('an_email@domain.com').for(:email)

  should_not allow_value('xxx').for(:currency)
  should allow_value('USD').for(:currency)

  context "required_organizations" do
    context "when require_organiation_membership is true" do
      context "and the location has organizations" do
        should "be the organizations" do
          location = Location.new
          location.organizations << Organization.new
          location.require_organization_membership = true
          assert location.required_organizations == location.organizations
        end
      end
    end
    context "when require_organization_membership is false" do
      should "be empty" do
        location = Location.new
        location.organizations << Organization.new
        assert location.required_organizations.none?
      end
    end
  end

  context "availability" do
    should "return an Availability::Summary for the Location's availability rules" do
      location = Location.new
      location.availability_rules << AvailabilityRule.new(:day => 0, :open_hour => 6, :open_minute => 0, :close_hour => 20, :close_minute => 0)

      assert location.availability.is_a?(AvailabilityRule::Summary)
      assert location.availability.open_on?(:day => 0, :hour => 6)
      assert !location.availability.open_on?(:day => 1)
    end
  end
end
