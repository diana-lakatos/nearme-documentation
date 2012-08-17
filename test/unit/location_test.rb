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
end
