require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  should validate_presence_of(:name)

  setup do
    @instance = Instance.first
  end

  context 'availability_templates' do
    should 'should have 2 availability_templates' do
      @new_instance = FactoryGirl.create(:instance)
      @new_instance.set_context!
      assert_equal 2, @new_instance.availability_templates.count
      assert_equal ['24/7', 'Working Week'], @new_instance.availability_templates.pluck(:name).sort
    end
  end

  context 'imap' do

    setup do
      @support_settings = {
        support_imap_username: 'supportteam@desksnear.me',
        support_imap_password: 'pass',
        support_imap_server: 'imap.gmail.com',
        support_imap_port: 993,
        support_imap_ssl: true
      }
    end

    should 'not be considered with imap if it is blank' do
      @instance.update_attributes(@support_settings.merge({support_imap_username: ''}))
      assert_equal 0, Instance.with_support_imap.count
    end

    should 'not be considered with imap if it is nil' do
      @instance.update_attributes(@support_settings.merge({support_imap_username: nil}))
      assert_equal 0, Instance.with_support_imap.count
    end

    should 'not be considered with imap if it is filled' do
      @instance.update_attributes(@support_settings)
      assert_equal 1, Instance.with_support_imap.count
    end
  end

  context 'instance owner' do
    setup do
      @instance_owner = FactoryGirl.create(:instance_admin)
      @instance.instance_admins << @instance_owner
      @instance.save
    end

    should 'return the instance owner' do
      assert @instance_owner.user, @instance.instance_owner
    end
  end

  context 'buyable_transactable_type' do
    setup do
      @transactable_type_buy_sell = FactoryGirl.create(:transactable_type_buy_sell, instance: @instance)
    end

    should 'return buyable transactable type' do
      assert_equal @instance.transactable_types.count, 2
      assert_equal @instance.buyable_transactable_type, @transactable_type_buy_sell
    end
  end
end
