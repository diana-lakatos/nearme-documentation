require 'test_helper'

class SellerAttachmentTest < ActiveSupport::TestCase

  setup do
    @attachment = FactoryGirl.create(:seller_attachment, access_level: 'users')
    @instance = @attachment.instance
    @user = @attachment.user
  end

  context '#access_level' do

    should 'return none if seller attachments disabled for instance' do
      @instance.update_column :seller_attachments_access_level, 'disabled'
      assert_equal 'disabled', @attachment.reload.access_level
    end

    should 'return instance access level unless it is iset to sellers preference' do
      assert_equal 'all', @attachment.access_level
    end

    should 'return objects access level if instances access level set to sellers preference' do
      @instance.update_column :seller_attachments_access_level, 'sellers_preference'
      assert_equal 'users', @attachment.reload.access_level
    end
  end

  context '#set_initial_access_level' do

    should 'set to instance access level unless it is not set to sellers_preference' do
      @instance.update_column :seller_attachments_access_level, 'users'
      @attachment.set_initial_access_level
      assert_equal 'users', @attachment.access_level
    end

    should 'set to all if instance access level is set to sellers preference' do
      @instance.update_column :seller_attachments_access_level, 'sellers_preference'
      @attachment.set_initial_access_level
      assert_equal 'all', @attachment.access_level
    end
  end

  context '#accessible_to?' do
    context 'all' do
      should 'be always accessible' do
        @attachment.stubs(access_level: 'all')
        assert @attachment.accessible_to?(nil)
      end
    end

    context 'users' do
      setup do
        @attachment.stubs(access_level: 'users')
      end

      should 'be accessible is user is logged in of access level is users' do
        assert @attachment.accessible_to?(@user)
      end

      should 'not be accessible unless user is logged in' do
        refute @attachment.accessible_to?(nil)
      end
    end

    context 'purchasers' do
      setup do
        @attachment.stubs(access_level: 'purchasers')
      end

      should 'be accessible if user has reservation' do
        @user.stubs(reservations: stub(confirmed: stub(find_by: true)))
        assert @attachment.accessible_to?(@user)
      end

      should 'be accessible if user bought product' do
        @attachment.assetable = FactoryGirl.create(:product)
        @user.stubs(orders: stub(complete: stub(map: stub(flatten: stub(include?: true)))))
        assert @attachment.accessible_to?(@user)
      end

      should 'not be accessible if user has no products or reservations' do
        refute @attachment.accessible_to?(@user)
      end
    end

    context 'disabled' do
      should 'raise argument error' do
        assert_raises do
          @attachment.stubs(access_level: 'disabled')
          @attachment.accessible_to?(@user)
        end
      end
    end
  end

  context '#attachments_num' do
    should 'add validation error if attachment exceeds instances attachments_num' do
      transactable = FactoryGirl.create(:transactable)
      10.times { FactoryGirl.create(:seller_attachment, user: @user, instance: @instance, assetable: transactable) }
      attachment = FactoryGirl.build(:seller_attachment, user: @user, instance: @instance, assetable: transactable)
      refute attachment.valid?
      assert attachment.errors.has_key?(:base)
      assert_equal I18n.t('seller_attachments.max_num_reached'), attachment.errors[:base][0]
    end
  end

end
