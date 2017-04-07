# frozen_string_literal: true
require 'test_helper'

class Dashboard::Company::TransactableTypes::TransactablesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company, creator: @user)
    @location = FactoryGirl.create(:location, company: @company)
    @location2 = FactoryGirl.create(:location, company: @company)
    @listing_type = 'Desk'
    @transactable_type = TransactableType.first
  end

  context '#new' do
    should 'display available Waiver Agreement check boxes' do
      @waiver_agreement_template1 = FactoryGirl.create(:waiver_agreement_template, target: @company)
      @waiver_agreement_template2 = FactoryGirl.create(:waiver_agreement_template, target: @company)
      @waiver_agreement_template3 = FactoryGirl.create(:waiver_agreement_template, target: @company)
      get :new, transactable_type_id: @transactable_type.id
      assert_select 'label', @waiver_agreement_template1.name
      assert_select 'label', @waiver_agreement_template2.name
      assert_select 'label', @waiver_agreement_template3.name
    end
  end

  context '#create' do
    setup do
      @attributes = FactoryGirl.attributes_for(:transactable).reverse_merge({ transactable_type_id: TransactableType.first.id,
                                                                              photos_attributes: [FactoryGirl.attributes_for(:photo)],
                                                                              properties: { listing_type: @listing_type },
                                                                              description: 'Aliquid eos ab quia officiis sequi.',
                                                                              name: "Listing #{Random.rand(1000)}" }
        .merge(action_type_attibutes(nil, 10, 1, 'day')))
      @attributes.delete(:photo_not_required)
    end

    should 'create transactable' do
      assert_difference('@location2.listings.count') do
        post :create, transactable: @attributes.merge(location_id: @location2.id), transactable_type_id: @transactable_type.id
      end
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type)
    end

    context 'different subunit to unit conversion rate' do
      should 'work for currencies with 1 to 1 ratio' do
        post :create, transactable: @attributes.merge(location_id: @location2.id, currency: 'JPY'), transactable_type_id: @transactable_type.id
        assert_equal 10.to_money('JPY'), assigns(:transactable).action_type.day_pricings.first.price
      end

      should 'work for currencies with 5 to 1 ratio' do
        post :create, transactable: @attributes.merge(location_id: @location2.id, currency: 'MGA'), transactable_type_id: @transactable_type.id
        assert_equal 10.to_money('MGA'), assigns(:transactable).action_type.day_pricings.first.price
      end

      should 'work for currencies with 1000 to 1 ratio' do
        post :create, transactable: @attributes.merge(location_id: @location2.id, currency: 'BHD'), transactable_type_id: @transactable_type.id
        assert_equal 10.to_money('BHD'), assigns(:transactable).action_type.day_pricings.first.price
      end
    end

    should 'not create transactable with custom validator' do
      @transactable_type.custom_validators.create(field_name: 'name', max_length: 5)
      @transactable_type.update_column :enable_photo_required, false
      @attributes.delete(:photos_attributes)

      assert_no_difference('@location2.listings.count') do
        post :create, transactable: @attributes.merge(location_id: @location2.id), transactable_type_id: @transactable_type.id
      end
      assert_template :new
    end
  end

  context 'with transactable' do
    setup do
      @transactable = FactoryGirl.create(:transactable, location: @location, photos_count: 1, quantity: 2)
    end

    context 'CRUD' do
      setup do
        @related_instance = FactoryGirl.create(:instance)
        FactoryGirl.create(:domain, target_id: @related_instance.id)
        PlatformContext.current = PlatformContext.new(@related_instance)
        @user = FactoryGirl.create(:user)
        sign_in @user
        @transactable_type = FactoryGirl.create(:transactable_type_listing)

        @related_company = FactoryGirl.create(:company_in_auckland, creator_id: @user.id, instance: @related_instance)
        @related_location = FactoryGirl.create(:location_in_auckland, company: @related_company)
        @related_transactable = FactoryGirl.create(:transactable, :with_time_based_booking, location: @related_location, photos_count: 1)
      end

      context '#edit' do
        should 'allow show edit form for related transactable' do
          get :edit, id: @related_transactable.id, transactable_type_id: @transactable_type.id
          assert_response :success
        end

        should 'not allow show edit form for unrelated transactable' do
          assert_raises(Transactable::NotFound) do
            get :edit, id: @transactable.id, transactable_type_id: @transactable_type.id
          end
        end
      end

      context '#update' do
        should 'allow update for related transactable' do
          put :update, id: @related_transactable.id, transactable: { name: 'new name' }.merge(action_type_attibutes(@related_transactable.action_type, 10, 1, 'day')), transactable_type_id: @transactable_type.id
          @related_transactable.reload
          assert_equal 'new name', @related_transactable.name
          assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type)
        end

        should 'properly update price if currency is set to JPY' do
          @related_transactable.update_attribute(:currency, 'JPY')
          put :update, id: @related_transactable.id, transactable: action_type_attibutes(@related_transactable.action_type, 100, 1, 'day'), transactable_type_id: @transactable_type.id
          @related_transactable.reload
          assert_equal 100.to_money('JPY'), @related_transactable.action_type.day_pricings.first.price
        end

        should 'properly update price if currency changes' do
          put :update, id: @related_transactable.id, transactable: { currency: 'JPY' }.merge(action_type_attibutes(@related_transactable.action_type, 100, 1, 'day')), transactable_type_id: @transactable_type.id
          @related_transactable.reload
          assert_equal 100.to_money('JPY'), @related_transactable.action_type.day_pricings.first.price
        end
      end

      context '#destroy' do
        should 'allow destroy for related transactable' do
          assert_difference 'Transactable.count', -1 do
            delete :destroy, id: @related_transactable.id, transactable_type_id: @transactable_type.id
          end
          assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type)
        end

        should 'not allow destroy for unrelated transactable' do
          assert_no_difference('Transactable.count') do
            assert_raises(Transactable::NotFound) { delete :destroy, id: @transactable.id, transactable_type_id: @transactable_type.id }
          end
        end
      end
    end

    should 'update transactable' do
      put :update, id: @transactable.id, transactable: { name: 'new name' }.merge(action_type_attibutes(@transactable.action_type, 10, 1, 'day')), transactable_type_id: @transactable_type.id
      @transactable.reload
      assert_equal 'new name', @transactable.name
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type)
    end

    should 'destroy transactable' do
      assert_difference('@user.listings.count', -1) do
        delete :destroy, id: @transactable.id, transactable_type_id: @transactable_type.id
      end

      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type)
    end

    context 'with reservation' do
      setup do
        stub_active_merchant_interaction
        @reservation1 = FactoryGirl.create(:future_unconfirmed_reservation, transactable: @transactable)
        @reservation2 = FactoryGirl.create(:future_unconfirmed_reservation, transactable: @transactable)
      end

      should 'notify guest about reservation expiration when listing is deleted' do
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::Expired, @reservation1.id)
        WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::Expired, @reservation2.id)
        delete :destroy, id: @transactable.id, transactable_type_id: @transactable_type.id
      end

      should 'mark reservations as expired' do
        delete :destroy, id: @transactable.id, transactable_type_id: @transactable_type.id
        assert_equal 'expired', @reservation1.reload.state
        assert_equal 'expired', @reservation2.reload.state
      end
    end

    context 'someone else tries to manage our listing' do
      setup do
        @other_user = FactoryGirl.create(:user)
        @other_company = FactoryGirl.create(:company, creator: @other_user)
        @other_location = FactoryGirl.create(:location, company: @company)
        sign_in @other_user
      end

      should 'handle lack of permission to edit properly' do
        assert_raise Transactable::NotFound do
          get :edit, id: @transactable.id, transactable_type_id: @transactable_type.id
        end
      end

      should 'not update listing' do
        assert_raise Transactable::NotFound do
          put :update, id: @transactable.id, listing: { name: 'new name' }, transactable_type_id: @transactable_type.id
        end
      end

      should 'not destroy listing' do
        assert_raise Transactable::NotFound do
          delete :destroy, id: @transactable.id, transactable_type_id: @transactable_type.id
        end
      end
    end
  end

  context 'versions' do
    should 'track version change on create' do
      @attributes = FactoryGirl.attributes_for(:transactable).reverse_merge({ transactable_type_id: TransactableType.first.id, photos_attributes: [FactoryGirl.attributes_for(:photo)], properties: { listing_type: @listing_type }, description: 'Aliquid eos ab quia officiis sequi.', name: "Listing #{Random.rand(1000)}" }.merge(action_type_attibutes(nil, 10, 1, 'day')))
      @attributes.delete(:photo_not_required)
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Transactable", "create").count') do
        with_versioning do
          post :create, transactable: @attributes.merge(location_id: @location2.id), transactable_type_id: @transactable_type.id
        end
      end
    end

    should 'track version change on update' do
      @transactable = FactoryGirl.create(:transactable, location: @location, quantity: 2, photos_count: 1)
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Transactable", "update").count') do
        with_versioning do
          put :update, id: @transactable.id, transactable: { name: 'new name' }, transactable_type_id: @transactable_type.id
        end
      end
    end

    should 'track version change on destroy' do
      @transactable = FactoryGirl.create(:transactable, location: @location, quantity: 2)
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Transactable", "destroy").count') do
        with_versioning do
          delete :destroy, id: @transactable.id, transactable_type_id: @transactable_type.id
        end
      end
    end
  end

  def action_type_attibutes(action_type, price, number_of_units, unit)
    pricing = action_type && action_type.pricing_for("#{number_of_units}_#{unit}")
    {
      action_types_attributes: [{
        transactable_type_action_type_id: TransactableType.first.action_types.first.id,
        enabled: 'true',
        type: action_type.try(:type) || 'Transactable::TimeBasedBooking',
        id: action_type.try(:id),
        pricings_attributes: [{
          transactable_type_pricing_id: TransactableType.first.time_based_booking.pricing_for([number_of_units, unit].join('_')).try(:id),
          enabled: '1',
          id: pricing.try(:id),
          price: price,
          number_of_units: number_of_units,
          unit: unit
        }]
      }]
    }
  end
end
