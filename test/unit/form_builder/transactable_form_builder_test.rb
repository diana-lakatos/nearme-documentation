# frozen_string_literal: true
require 'test_helper'
require 'helpers/gmaps_fake'

class TransactableFormBuilderTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @transactable_type = FactoryGirl.create(:transactable_type,
      enable_photo_required: false,
      searchable: false,
      skip_location: true
    )
  end

  should 'save transactable' do
    transactable_form = form(
      offer_action: {
        pricings: { validation: { length: { minimum: 1 }, if: :enabled? } },
        validation: { presence: true }
      },
      action_type: { validation: { presence: true, length: { minimum: 1 } } }
    )
    params = {
      'offer_action_attributes' => {
        transactable_type_action_type_id: @transactable_type.action_types.first.id,
        type: 'Transactable::OfferAction',
        enabled: 'true',
        'pricings_attributes' => {
          '0' => {
            price: 105,
            enabled: '1',
            transactable_type_pricing_id: @transactable_type.action_types.first.pricings.first.id
          }
        }
      }
    }
    assert transactable_form.validate(params), transactable_form.errors.messages
    assert_difference 'Transactable.count', 1, transactable_form.errors.messages do
      transactable_form.save
    end
  end

  should 'save transactable with location' do
    GmapsFake.stub_requests
    transactable_form = form(
      offer_action: {
        pricings: { validation: { length: { minimum: 1 }, if: :enabled? } },
        validation: { presence: true }
      },
      action_type: { validation: { presence: true, length: { minimum: 1 } } },
      location: {
        name: { validation: { presence: true } },
        company_id: {},
        location_address: {
          address: { validation: { presence: true } }
        }
      }
    )
    params = {
      'offer_action_attributes' => {
        transactable_type_action_type_id: @transactable_type.action_types.first.id,
        type: 'Transactable::OfferAction',
        enabled: 'true',
        'pricings_attributes' => {
          '0' => {
            price: 105,
            enabled: '1',
            transactable_type_pricing_id: @transactable_type.action_types.first.pricings.first.id
          }
        }
      },
      'location_attributes' => {
        name: 'My Location',
        company_id: @company.id,
        'location_address_attributes' => {
          'address' => 'adelaide'
        }
      }
    }
    assert transactable_form.validate(params), transactable_form.errors.messages
    assert_difference 'Transactable.count', 1, [transactable_form.errors.messages, transactable_form.model.errors.messages] do
      transactable_form.save
    end
    transactable = Transactable.last
    assert transactable.location.location_address.address
  end

  def form(config)
    FormBuilder.new(
      base_form: TransactableForm,
      configuration: config,
      object: @transactable_type.transactables.new(creator: @user, location_not_required: true)
    ).build
  end
end
