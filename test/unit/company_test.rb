require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  should belong_to(:creator)
  should have_many(:locations)
  should have_many(:industries)
  should validate_presence_of(:name)
  should_not allow_value('not_an_email').for(:email)
  should allow_value('an_email@domain.com').for(:email)
  should_not allow_value('not a url!').for(:url)
  should allow_value('http://a-url.com').for(:url)
  should allow_value('a-url.com').for(:url)
  should allow_value('x' * 250).for(:description)
  should_not allow_value('x' * 251).for(:description)

  should "be valid even if its location is not valid" do
    @company = FactoryGirl.create(:company)
    @location = FactoryGirl.create(:location, :company => @company)
    @location.address = nil
    @location.save(:validate => false)
    @company.reload
    assert @company.valid?
  end
end
