# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class OrdersControllerTest < ActionController::TestCase
        setup do
          @reservation = FactoryGirl.create(:unconfirmed_reservation)
        end

        context 'enquirer' do
          setup do
            sign_in @reservation.user
          end

          should 'not be able to confirm reservation' do
            assert_raise ArgumentError do
              put :update, form_configuration_id: confirm_form_configuration.id,
                           id: @reservation.id
            end
            assert_not_equal 'confirmed', @reservation.reload.state
          end

          should 'be able to user cancel reservation' do
            Reservation.any_instance.expects(:schedule_void).once
            put :update, form_configuration_id: user_cancel_form_configuration.id,
                         id: @reservation.id
            assert_equal 'cancelled_by_guest', @reservation.reload.state
          end

          should 'not be able to host cancel reservation' do
            assert_raise ArgumentError do
              put :update, form_configuration_id: host_cancel_form_configuration.id,
                           id: @reservation.id
            end
            assert_not_equal 'cancelled_by_host', @reservation.reload.state
          end

          should 'not be able to reject reservation' do
            assert_raise ArgumentError do
              put :update, form_configuration_id: reject_form_configuration.id,
                           id: @reservation.id
            end
            assert_not_equal 'rejected', @reservation.reload.state
          end

          should 'not be able to lister confirm as enquirer' do
            put :update, form_configuration_id: lister_confirm_form_configuration.id,
                         id: @reservation.id
            assert_nil @reservation.reload.lister_confirmed_at
          end
        end

        context 'lister' do
          setup do
            sign_in @reservation.creator
          end

          should 'be able to create Offer' do
            transactable = FactoryGirl.create(:transactable_offer)
            assert_difference 'Offer.count' do
              post :create,
                   form_configuration_id: create_offer_form.id,
                   form: {
                     transactable_pricing_id: transactable.action_type.pricings.first.id,
                     transactable_id: transactable.id,
                     reservation_type_id: transactable.transactable_type.reservation_type.id
                   }
            end
            offer = Order.last
            assert Offer, offer.class
            assert 'unconfirmed', offer.state
          end

          should 'be able to confirm reservation' do
            put :update, form_configuration_id: confirm_form_configuration.id,
                         id: @reservation.id
            assert_equal 'confirmed', @reservation.reload.state
          end

          should 'not be able to user cancel reservation' do
            assert_raise ArgumentError do
              put :update, form_configuration_id: user_cancel_form_configuration.id,
                           id: @reservation.id
            end
            assert_not_equal 'cancelled_by_guest', @reservation.reload.state
          end

          should 'be able to host cancel reservation' do
            put :update, form_configuration_id: host_cancel_form_configuration.id,
                         id: @reservation.id
            assert_equal 'cancelled_by_host', @reservation.reload.state
          end

          should 'be able to reject reservation' do
            Reservation.any_instance.expects(:schedule_void).once
            put :update, form_configuration_id: reject_form_configuration.id,
                         id: @reservation.id
            assert_equal 'rejected', @reservation.reload.state
          end

          should 'able to lister confirm as lister' do
            put :update, form_configuration_id: lister_confirm_form_configuration.id,
                         id: @reservation.id
            assert_not_nil @reservation.reload.lister_confirmed_at
          end

          should 'able to capture payment' do
            Payment.any_instance.expects(:capture!).once
            put :update, form_configuration_id: with_charge_form_configuration.id,
                         id: @reservation.id
          end

          should 'call custom actions on confirm reservation' do
            FactoryGirl.create(
              :form_configuration,
              name: 'delete_invitation_form',
              base_form: 'CustomizationForm',
              configuration: {
              }
            )
            query = %(mutation invitation_delete($id: ID!, $form_configuration: String!){
              customization_delete(id: $id, form_configuration: $form_configuration){ id }
            })
            FactoryGirl.create(:graph_query, name: 'invitation_delete', query_string: query)
            customization = add_custom_model(model_name: 'Cars', attr_name: 'model_attr', object: @reservation.creator.default_profile)
            confirm_form_configuration.update_attributes!(
              callback_actions: "{% query_graph invitation_delete, id: #{customization.id}, form_configuration: \"delete_invitation_form\" %}"
            )
            put :update, form_configuration_id: confirm_form_configuration.id,
                         id: @reservation.id

            assert_equal 'confirmed', @reservation.reload.state
            refute Customization.exists?(customization.id)
          end
        end

        protected

        def reject_form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'order_form',
            base_form: 'OrderForm',
            configuration: {
              state_event: { property_options: { default: 'reject', readonly: true } }
            }
          )
        end

        def confirm_form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'order_form',
            base_form: 'OrderForm',
            configuration: {
              state_event: { property_options: { default: 'confirm', readonly: true } }
            }
          )
        end

        def user_cancel_form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'order_form',
            base_form: 'OrderForm',
            configuration: {
              state_event: { property_options: { default: 'user_cancel', readonly: true } }
            }
          )
        end

        def host_cancel_form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'order_form',
            base_form: 'OrderForm',
            configuration: {
              state_event: { property_options: { default: 'host_cancel', readonly: true } }
            }
          )
        end

        def lister_confirm_form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'order_form',
            base_form: 'OrderForm',
            configuration: {
              lister_confirm: {
                property_options: {
                  virtual: true,
                  readonly: true,
                  default: true
                }
              }
            }
          )
        end

        def with_charge_form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'order_form',
            base_form: 'OrderForm',
            configuration: {
              with_charge: {
                property_options: {
                  virtual: true,
                  readonly: true,
                  default: true
                }
              }
            }
          )
        end

        def create_offer_form
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'create_offer_form',
            base_form: 'OfferForm',
            configuration: {
              state_event: {
                property_options: {
                  default: 'activate',
                  readonly: true
                }
              }
            }
          )
        end

        def add_custom_model(model_name:, attr_name:, object:)
          default_profile_type = PlatformContext.current.instance.default_profile_type
          model = FactoryGirl.create(:custom_model_type, name: model_name, instance_profile_types: [default_profile_type])
          FactoryGirl.create(:custom_attribute, name: attr_name, target: model)
          customization = Customization.new(custom_model_type: model, properties: { attr_name => 'mazda' })
          object.customizations << customization
          customization
        end
      end
    end
  end
end
