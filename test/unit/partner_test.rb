require 'test_helper'

class PartnerTest < ActiveSupport::TestCase
  should validate_presence_of(:name)

  setup do
    @partner = FactoryGirl.create(:partner)
  end

  context 'theme does not exists' do
    context 'partner is persisted' do
      should "return instance's theme" do
        assert_equal @partner.instance.theme, @partner.theme
      end
    end

    context 'partner is not persisted' do
      setup do
        @partner = FactoryGirl.build(:partner, instance: Instance.first)
        @instance_theme = @partner.instance.theme
        @partner_theme = @partner.theme
      end

      should 'have blank name' do
        assert @partner_theme.name.blank?
      end

      should "return parent instance's values if does not exist" do
        assert_equal @instance_theme.site_name, @partner_theme.site_name
      end
    end
  end

  should "return partner's theme if exists" do
    @theme1 = FactoryGirl.create(:theme, owner_id: @partner.id, owner_type: 'Partner')
    assert_equal @theme1, @partner.theme
  end
end
