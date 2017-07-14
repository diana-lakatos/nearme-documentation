# frozen_string_literal: true
require 'test_helper'
require 'helpers/gmaps_fake'

module Api
  module V4
    module User
      class TransactablesControllerTest < ActionController::TestCase
        setup do
          enable_elasticsearch!
          @user = FactoryGirl.create(:user)
          sign_in @user
          @company = FactoryGirl.create(:company, creator: @user)
          @transactable_type = FactoryGirl.create(:transactable_type,
                                                  enable_photo_required: false,
                                                  searchable: false,
                                                  skip_location: true)
        end

        def teardown
          disable_elasticsearch!
        end

        should 'create transactable' do
          GmapsFake.stub_requests
          Elastic::Commands::InstantIndexRecord.any_instance.expects(:call).once

          assert_difference 'Transactable.count' do
            post :create, form_configuration_id: form_configuration.id,
                          transactable: transactable_attributes,
                          transactable_type_id: @transactable_type.id
          end

          assert_response :redirect
        end

        should 'update transactable' do
          transactable = FactoryGirl.create(:transactable, transactable_type: @transactable_type, creator: @user)
          Elastic::Commands::InstantIndexRecord.any_instance.expects(:call).once

          put :update, id: transactable.id,
                       form_configuration_id: form_configuration.id,
                       transactable_type_id: @transactable_type.id,
                       transactable: transactable_attributes

          assert_response :redirect
        end

        protected

        def form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'transactable_form',
            base_form: 'TransactableForm',
            configuration: {
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
            }
          )
        end

        def transactable_attributes
          {
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
        end
      end
    end
  end
end
