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
              post :update, form_configuration_id: confirm_form_configuration.id,
                            id: @reservation.id
            end
            assert_not_equal 'confirmed', @reservation.reload.state
          end

          should 'be able to user cancel reservation' do
            Reservation.any_instance.expects(:schedule_void).once
            post :update, form_configuration_id: user_cancel_form_configuration.id,
                          id: @reservation.id
            assert_equal 'cancelled_by_guest', @reservation.reload.state
          end

          should 'not be able to host cancel reservation' do
            assert_raise ArgumentError do
              post :update, form_configuration_id: host_cancel_form_configuration.id,
                            id: @reservation.id
            end
            assert_not_equal 'cancelled_by_host', @reservation.reload.state
          end

          should 'not be able to reject reservation' do
            assert_raise ArgumentError do
              post :update, form_configuration_id: reject_form_configuration.id,
                            id: @reservation.id
            end
            assert_not_equal 'rejected', @reservation.reload.state
          end

          should 'not be able to lister confirm as enquirer' do
            post :update, form_configuration_id: lister_confirm_form_configuration.id,
                          id: @reservation.id
            assert_nil @reservation.reload.lister_confirmed_at
          end
        end

        context 'lister' do
          setup do
            sign_in @reservation.creator
          end

          should 'be able to confirm reservation' do
            post :update, form_configuration_id: confirm_form_configuration.id,
                          id: @reservation.id
            assert_equal 'confirmed', @reservation.reload.state
          end

          should 'not be able to user cancel reservation' do
            assert_raise ArgumentError do
              post :update, form_configuration_id: user_cancel_form_configuration.id,
                            id: @reservation.id
            end
            assert_not_equal 'cancelled_by_guest', @reservation.reload.state
          end

          should 'be able to host cancel reservation' do
            post :update, form_configuration_id: host_cancel_form_configuration.id,
                          id: @reservation.id
            assert_equal 'cancelled_by_host', @reservation.reload.state
          end

          should 'be able to reject reservation' do
            Reservation.any_instance.expects(:schedule_void).once
            post :update, form_configuration_id: reject_form_configuration.id,
                          id: @reservation.id
            assert_equal 'rejected', @reservation.reload.state
          end

          should 'able to lister confirm as lister' do
            post :update, form_configuration_id: lister_confirm_form_configuration.id,
                          id: @reservation.id
            assert_not_nil @reservation.reload.lister_confirmed_at
          end

          should 'able to capture payment' do
            Payment.any_instance.expects(:capture!).once
            post :update, form_configuration_id: with_charge_form_configuration.id,
                          id: @reservation.id
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

      end
    end
  end
end
