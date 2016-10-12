require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:name)
  should validate_presence_of(:name)
  should validate_presence_of(:target_type)

  setup do
    @desks_near_me_domain = FactoryGirl.create(:domain, name: 'desksnearme.com', target: FactoryGirl.create(:instance))
    @company = FactoryGirl.create(:company)
    @example_domain = FactoryGirl.create(:domain, name: 'company.example.com', target: @company, target_type: 'Company')
    @partner_domain = FactoryGirl.create(:domain, name: 'partner.example.com', target: FactoryGirl.create(:partner), target_type: 'Partner')
  end

  context 'target' do
    should 'be able to detect that its target is instance' do
      assert @desks_near_me_domain.instance?
      assert !@desks_near_me_domain.white_label_company?
      assert !@example_domain.partner?
    end

    should 'be able to detect that its target is company' do
      assert @example_domain.white_label_company?
      assert !@example_domain.instance?
      assert !@example_domain.partner?
    end

    should 'be able to detect that its target is partner' do
      assert @partner_domain.partner?
      assert !@partner_domain.white_label_company?
      assert !@partner_domain.instance?
    end
  end

  context 'validation' do
    should 'allow to remove random domain' do
      domain = FactoryGirl.create(:domain, name: 'somedomain.com')
      assert domain.destroy
    end

    should 'allow to remove *near-me.com domain' do
      domain = FactoryGirl.create(:domain, name: 'somedomainnear-me.com')
      assert domain.destroy
    end

    should 'allow to remove *near-me.com* domain' do
      domain = FactoryGirl.create(:domain, name: 'near-me.company.com')
      assert domain.destroy
    end

    should 'not allow to remove *.near-me.com$ domain' do
      domain = FactoryGirl.create(:domain, name: 'domain.near-me.com')
      refute domain.destroy
    end

    context 'name uniqueness' do
      should 'be able to re-add deleted name' do
        domain = FactoryGirl.create(:domain, name: 'name.com')
        FactoryGirl.create(:domain, target: domain.target)
        assert domain.destroy
        assert_nothing_raised do
          FactoryGirl.create(:domain, name: 'name.com')
        end
      end

      should 'not create duplicated active domain' do
        domain = FactoryGirl.create(:domain, name: 'name.com', deleted_at: Time.zone.now)
        FactoryGirl.create(:domain, name: 'name.com')
        assert_raise ActiveRecord::RecordNotUnique do
          domain.restore!
        end
        assert_raise ActiveRecord::RecordInvalid do
          FactoryGirl.create(:domain, name: 'name.com')
        end
      end
    end
  end

  context 'redirect' do
    should 'be able to recognize redirection' do
      refute @desks_near_me_domain.redirect?

      @desks_near_me_domain.update_attributes redirect_to: 'http://another-web.com', redirect_code: 302
      assert @desks_near_me_domain.redirect?
    end
  end
end
