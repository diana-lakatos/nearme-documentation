require 'test_helper'

class IndustryTest < ActiveSupport::TestCase

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)

  context 'with at least one listing' do

    setup do
      Industry.destroy_all
      3.times do |i|
        @industry_with_listings = FactoryGirl.create(:industry, :name => "with listing #{i}")
        set_up_company_with_various_listings(@industry_with_listings)
      end
      @industry_without_listing = FactoryGirl.create(:industry, :name => 'without listing')
      CompanyIndustry.create(:industry_id => @industry_with_listings.id, :company_id => @company.id)
    end

    should 'return only industries with at least one listing' do
      assert_equal [Industry.find_by_name('with listing 0'), Industry.find_by_name('with listing 1'), Industry.find_by_name('with listing 2')].sort, Industry.with_listings.all.sort
    end

    should 'ignore if only not searchable listings' do
      Industry.find_by_name('with listing 0').listings.searchable.destroy_all
      assert_equal [Industry.find_by_name('with listing 1'), Industry.find_by_name('with listing 2')].sort, Industry.with_listings.all.sort
    end

  end

  context 'metadata' do
    context 'populate_companies_industries_metadata!' do

      setup do
        @company = FactoryGirl.create(:company)
        @industry = @company.industries.first
      end

      should 'trigger populate_companies_industries after update' do
        Company.any_instance.expects(:populate_industries_metadata!)
        @industry.update_attribute(:name, 'new name')
      end

      should 'trigger populate_companies_industries after destroy' do
        Company.any_instance.expects(:populate_industries_metadata!)
        @industry.destroy
      end

    end
  end

  private

  def set_up_company_with_various_listings(industry)
    @company = FactoryGirl.create(:company, industries: [industry])
    @location = FactoryGirl.create(:location, :company => @company)
    3.times do
      FactoryGirl.create(:transactable, :location => @location)
    end
    FactoryGirl.create(:transactable, :draft => Time.zone.now, :location => @location)
    FactoryGirl.create(:transactable, :enabled => false, :location => @location)
  end

end
