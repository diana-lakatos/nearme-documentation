require 'test_helper'

class CompanyIndustryTest < ActiveSupport::TestCase

  context 'metadata' do
    context 'populate_companies_industries_metadata!' do
      setup do
        @company = FactoryGirl.create(:company)
        @industry = FactoryGirl.create(:industry)
      end

      should 'trigger populate_companies_industries after update' do
        Company.any_instance.expects(:populate_industries_metadata!)
        FactoryGirl.create(:company_industry, :company => @company, :industry => @industry)
      end

      should 'trigger populate_companies_industries after destroy' do
        Company.any_instance.expects(:populate_industries_metadata!)
        @company.company_industries.first.destroy
      end
    end
  end

end
