require 'test_helper'

class PlatformContext::DynamicScopeAssigner < ActiveSupport::TestCase
  MODELS_SCOPEABLE_ONLY_TO_INSTANCE = [:amenity_type, :instance_admin, :instance_billing_gateway,
                                       :instance_client, :location_type, :user_message]
  MODELS_SCOPEABLE_TO_WHITE_LABEL_COMPANY_AND_PARTNER = [] # [:location, :transactable, :reservation, :payment, :payment_transfer]
  MODELS_WITH_LISTINGS_PUBLIC = [] # [:location, :transactable, :reservation]

  setup do
    PlatformContext.clear_current
    PlatformContext.current = PlatformContext.new(Instance.first)
  end

  context 'default scope' do
    setup do
      @instance = FactoryGirl.create(:instance, name: 'current')
      @other_instance = FactoryGirl.create(:instance, name: 'other')
    end

    context 'all models' do
      context 'instance' do
        # if we enter desksnear.me instance we don't want to see records from boatsnear.you instance
        should 'scope models to current instance' do
          ([:company] + MODELS_SCOPEABLE_ONLY_TO_INSTANCE + MODELS_SCOPEABLE_TO_WHITE_LABEL_COMPANY_AND_PARTNER).each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current = FactoryGirl.create(model_symbol)
            @current.update_column(:instance_id, @instance.id)
            @other = FactoryGirl.create(model_symbol)
            @other.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@instance)
            assert_equal [@current.id], model_symbol.to_s.camelize.constantize.pluck(:id)
          end
        end

        # if we enter desksnear.me instance we don't want to see records from privatecompany.desksnear.me
        should 'ignore entities that belong to company with private listings' do
          (MODELS_WITH_LISTINGS_PUBLIC).each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @public = FactoryGirl.create(model_symbol)
            @public.update_column(:instance_id, @instance.id)
            @public.update_column(:listings_public, true)
            @private = FactoryGirl.create(model_symbol)
            @private.update_column(:instance_id, @instance.id)
            @private.update_column(:listings_public, false)
            PlatformContext.current = PlatformContext.new(@instance)
            assert_equal [@public.id], model_symbol.to_s.camelize.constantize.pluck(:id)
          end
        end

        context 'instance admin' do
          # if we for example enter desksnear.me/instance_admin we actually want to see records even from privatecompany.desksnear.me
          should 'not scope entities that belong to company with private listings if scope forced to instance' do
            (MODELS_WITH_LISTINGS_PUBLIC).each do |model_symbol|
              PlatformContext.current = PlatformContext.new(Instance.first)
              model_symbol.to_s.camelize.constantize.destroy_all
              @public = FactoryGirl.create(model_symbol)
              @public.update_column(:instance_id, @instance.id)
              @public.update_column(:listings_public, true)
              @private = FactoryGirl.create(model_symbol)
              @private.update_column(:instance_id, @instance.id)
              @private.update_column(:listings_public, false)
              PlatformContext.current = PlatformContext.new(@instance)
              PlatformContext.scope_to_instance
              assert_equal [@public.id, @private.id].sort, model_symbol.to_s.camelize.constantize.pluck(:id).sort
            end
          end

          # if we for example enter privatecompany.desksnear.me/instance_admin we actually want to see records for all companies in this instance
          # despite we are on white label company domain.
          should 'not scope objects to company instance if scope forced to instance' do
            @company_instance = FactoryGirl.create(:instance)
            @current_company = FactoryGirl.create(:white_label_company)
            @current_company.update_attribute(:instance_id, @company_instance.id)
            @other_company = FactoryGirl.create(:white_label_company)
            @other_company.update_attribute(:instance_id, @company_instance.id)
            MODELS_SCOPEABLE_TO_WHITE_LABEL_COMPANY_AND_PARTNER.each do |model_symbol|
              PlatformContext.current = PlatformContext.new(Instance.first)
              model_symbol.to_s.camelize.constantize.destroy_all
              @current_object = FactoryGirl.create(model_symbol)
              @current_object.update_column(:instance_id, @instance.id)
              @company_object = FactoryGirl.create(model_symbol)
              @company_object.update_column(:company_id, @current_company.id)
              @company_object.update_column(:instance_id, @current_company.instance_id)
              @other_company_object = FactoryGirl.create(model_symbol)
              @other_company_object.update_column(:company_id, @other_company.id)
              @other_company_object.update_column(:instance_id, @other_company.instance_id)
              @other_object = FactoryGirl.create(model_symbol)
              @other_object.update_column(:instance_id, @other_instance.id)
              PlatformContext.current = PlatformContext.new(@current_company)
              PlatformContext.scope_to_instance
              assert_equal [@company_object.id, @other_company_object.id].sort, model_symbol.to_s.camelize.constantize.pluck(:id).sort
            end
          end
        end
      end

      context 'white label company' do
        setup do
          @company_instance = FactoryGirl.create(:instance)
          @current_company = FactoryGirl.create(:white_label_company)
          @current_company.update_attribute(:instance_id, @company_instance.id)
          @other_company = FactoryGirl.create(:white_label_company)
          @other_company.update_attribute(:instance_id, @company_instance.id)
        end

        # if we are on whitelabelcompany.com we want to see things related only to this company
        should 'scope company correctly' do
          PlatformContext.current = PlatformContext.new(@current_company)
          assert_equal [@current_company], Company.all
        end

        # if we are on whitelabelcompany.com we don't care if listings_public is true or false
        should 'accept listings_private setting if white label company' do
          @current_company.update_column(:listings_public, false)
          PlatformContext.current = PlatformContext.new(@current_company)
          assert_equal [@current_company], Company.all
        end

        # if we are on whitelabelcompany.com we want to see records only for this company
        should 'scope these objects to company' do
          # We do this here to ensure the white label companies we work with
          # have the same instance_id as the objects because in the app
          # we don't/can't have companies belonging to an instance and company
          # belonging to a different instance
          PlatformContext.current = PlatformContext.new(Instance.first)
          @this_current_company = FactoryGirl.create(:white_label_company)
          @this_other_company = FactoryGirl.create(:white_label_company)
          MODELS_SCOPEABLE_TO_WHITE_LABEL_COMPANY_AND_PARTNER.each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current_object = FactoryGirl.create(model_symbol)
            @current_object.update_column(:instance_id, @instance.id)
            @company_object = FactoryGirl.create(model_symbol)
            @company_object.update_column(:company_id, @this_current_company.id)
            @other_company_object = FactoryGirl.create(model_symbol)
            @other_company_object.update_column(:company_id, @this_other_company.id)
            @other_company_object.update_column(:instance_id, @this_other_company.instance_id)
            @other_object = FactoryGirl.create(model_symbol)
            @other_object.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@this_current_company)
            assert_equal [@company_object.id], model_symbol.to_s.camelize.constantize.pluck(:id)
          end
        end

        # some models should be scoped to white label company's instance
        should 'scope these objects to company instance' do
          MODELS_SCOPEABLE_ONLY_TO_INSTANCE.each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current_object = FactoryGirl.create(model_symbol)
            @current_object.update_column(:instance_id, @instance.id)
            @company_object = FactoryGirl.create(model_symbol)
            @company_object.update_column(:instance_id, @company_instance.id)
            @other_object = FactoryGirl.create(model_symbol)
            @other_object.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@current_company)
            assert_equal [@company_object], model_symbol.to_s.camelize.constantize.all
          end
        end
      end

      context 'scoped partner' do
        setup do
          @partner_instance = FactoryGirl.create(:instance)
          @partner = FactoryGirl.create(:partner)
          @partner.update_attribute(:instance_id, @partner_instance.id)
          @partner_company = FactoryGirl.create(:white_label_company)
          @partner_company.update_attribute(:instance_id, @partner_instance.id)
          @partner_company.update_attribute(:partner_id, @partner.id)
          @other_company = FactoryGirl.create(:white_label_company)
          @other_company.update_attribute(:instance_id, @partner_instance.id)
        end

        # if partner has scoping enabled, show only companies created via this partner's domain
        should 'scope company to partner' do
          PlatformContext.current = PlatformContext.new(@partner)
          assert_equal [@partner_company], Company.all
        end

        # if partner has scoping enabled, show only records created via this partner's domain
        should 'scope these objects to partner' do
          MODELS_SCOPEABLE_TO_WHITE_LABEL_COMPANY_AND_PARTNER.each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current_object = FactoryGirl.create(model_symbol)
            @current_object.update_column(:instance_id, @instance.id)
            @partner_object = FactoryGirl.create(model_symbol)
            @partner_object.update_column(:partner_id, @partner_company.partner_id)
            @partner_object.update_column(:instance_id, @partner_company.instance_id)
            @partner_object.update_column(:company_id, @partner_company.id)
            @other_company_object = FactoryGirl.create(model_symbol)
            @other_company_object.update_column(:instance_id, @other_company.instance_id)
            @other_company_object.update_column(:company_id, @other_company.id)
            @other_object = FactoryGirl.create(model_symbol)
            @other_object.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@partner)
            assert_equal [@partner_object.id], model_symbol.to_s.camelize.constantize.pluck(:id)
          end
        end

        # some objects should be scoped to partner's instance
        should 'scope these objects to partner instance' do
          MODELS_SCOPEABLE_ONLY_TO_INSTANCE.each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current_object = FactoryGirl.create(model_symbol)
            @current_object.update_column(:instance_id, @instance.id)
            @partner_object = FactoryGirl.create(model_symbol)
            @partner_object.update_column(:instance_id, @partner_instance.id)
            @other_object = FactoryGirl.create(model_symbol)
            @other_object.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@partner)
            assert_equal [@partner_object], model_symbol.to_s.camelize.constantize.all
          end
        end
      end

      context 'not scoped partner' do
        setup do
          @partner_instance = FactoryGirl.create(:instance)
          @partner = FactoryGirl.create(:partner_without_scoping)
          @partner.update_attribute(:instance_id, @partner_instance.id)
          @partner_company = FactoryGirl.create(:white_label_company)
          @partner_company.update_attribute(:instance_id, @partner_instance.id)
          @partner_company.update_attribute(:partner_id, @partner.id)
          @other_company = FactoryGirl.create(:white_label_company)
          @other_company.update_attribute(:instance_id, @partner_instance.id)
        end

        # if partner has scoping disabled, we want o show all companies that belong to partner's instance
        should 'scope company to partner instance' do
          PlatformContext.current = PlatformContext.new(@partner)
          assert_equal [@partner_company, @other_company].sort, Company.all.sort
        end

        # if partner has scoping disabled, we want o show records that belong to partner's instance
        should 'scope these objects to partner instance' do
          MODELS_SCOPEABLE_ONLY_TO_INSTANCE.each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current_object = FactoryGirl.create(model_symbol)
            @current_object.update_column(:instance_id, @instance.id)
            @partner_object = FactoryGirl.create(model_symbol)
            @partner_object.update_column(:instance_id, @partner_instance.id)
            @other_object = FactoryGirl.create(model_symbol)
            @other_object.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@partner)
            assert_equal [@partner_object], model_symbol.to_s.camelize.constantize.all
          end
        end

        # some objects can't be scoped to partner, but they should be scoped to partner's instance in this case
        should 'scope these objects partner instance instead of partner' do
          MODELS_SCOPEABLE_TO_WHITE_LABEL_COMPANY_AND_PARTNER.each do |model_symbol|
            PlatformContext.current = PlatformContext.new(Instance.first)
            model_symbol.to_s.camelize.constantize.destroy_all
            @current_object = FactoryGirl.create(model_symbol)
            @current_object.update_column(:instance_id, @instance.id)
            @partner_object = FactoryGirl.create(model_symbol)
            @partner_object.update_column(:partner_id, @partner_company.partner_id)
            @partner_object.update_column(:instance_id, @partner_company.instance_id)
            @other_company_object = FactoryGirl.create(model_symbol)
            @other_company_object.update_column(:instance_id, @partner_company.instance_id)
            @other_object = FactoryGirl.create(model_symbol)
            @other_object.update_column(:instance_id, @other_instance.id)
            PlatformContext.current = PlatformContext.new(@partner)
            assert_equal [@other_company_object.id, @partner_object.id].sort, model_symbol.to_s.camelize.constantize.pluck(:id).sort
          end
        end
      end
    end

    context 'specific models' do
      context 'instance_admin_role' do
        # there are 'global' roles that should be accessed via any instance
        should 'scope instance admin role to current instance or nil' do
          FactoryGirl.create(:instance_admin_role_default)
          FactoryGirl.create(:instance_admin_role_administrator)
          @current = FactoryGirl.create(:instance_admin_role)
          @current.update_attribute(:instance_id, @instance.id)
          @other = FactoryGirl.create(:instance_admin_role)
          @other.update_attribute(:instance_id, @other_instance.id)
          PlatformContext.current = PlatformContext.new(@instance)
          assert_equal [InstanceAdminRole.default_role, InstanceAdminRole.administrator_role, @current].sort, InstanceAdminRole.all.sort
          PlatformContext.current = PlatformContext.new(@other_instance)
          assert_equal [InstanceAdminRole.default_role, InstanceAdminRole.administrator_role, @other].sort, InstanceAdminRole.all.sort
        end
      end
    end
  end
end
