# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class ShoppingCartsControllerTest < ActionController::TestCase
        setup do
          @transactable = FactoryGirl.create(:listing_with_10_dollars_per_hour)
          @transactable.time_based_booking.update_attribute(:minimum_booking_minutes, 90)
          @reservation_type = ReservationType.last
          FactoryGirl.create(:custom_attribute, name: 'res_custom_attr', target: @reservation_type)
          @user = FactoryGirl.create(:user)
          sign_in @user
        end

        should 'be able to add reservation to shopping cart and update it later' do
          date = Date.current + 2.days
          start_minute = 700
          assert_difference 'ShoppingCart.count' do
            assert_difference 'Reservation.count' do
              assert_difference 'ReservationPeriod.count' do
                post :create, form_configuration_id: form_configuration.id,
                              form: {
                                orders: {
                                  :"#{@reservation_type.parameterized_name}" => {
                                    reservations_attributes: {
                                      '0' => {
                                        transactable_id: @transactable.id,
                                        transactable_pricing_id: @transactable.action_type.hour_pricings.first.id,
                                        periods_attributes: {
                                          '0' => {
                                            date: date.strftime('%Y-%m-%d'),
                                            start_minute: start_minute,
                                            hours: 2.5
                                          }
                                        },
                                        properties: {
                                          res_custom_attr: 'My cust value'
                                        }
                                      }
                                    }
                                  }
                                }
                              }
              end
            end
          end
          shopping_cart = @user.reload.current_shopping_cart
          refute shopping_cart.checkout_at
          reservation = shopping_cart.reservations.first
          assert_equal @transactable.id, reservation.transactable.id
          assert_equal 'inactive', reservation.state
          assert_equal 'My cust value', reservation.properties.res_custom_attr
          assert_equal 27_50, reservation.total_amount_cents.to_i
          assert_equal 250, reservation.service_fee_amount_guest_cents.to_i
          assert_equal 250, reservation.service_fee_amount_host_cents.to_i
          assert_equal date, reservation.periods.first.date
          assert_equal start_minute, reservation.periods.first.start_minute
          assert_equal 850, reservation.periods.first.end_minute
          post :update, form_configuration_id: form_configuration.id,
                        form: {
                          orders: {
                            :"#{@reservation_type.parameterized_name}_attributes" => {
                              reservations_attributes: {
                                '0' => {
                                  booking_type: 'hourly',
                                  transactable_id: @transactable.id,
                                  transactable_pricing_id: @transactable.action_type.hour_pricings.first.id,
                                  periods_attributes: {
                                    '0' => {
                                      date: date.strftime('%Y-%m-%d'),
                                      start_minute: start_minute,
                                      hours: 2.75
                                    }
                                  },
                                  properties: {
                                    res_custom_attr: 'My cust value'
                                  }
                                }
                              }
                            }
                          }
                        }
          shopping_cart = @user.reload.current_shopping_cart
          refute shopping_cart.checkout_at
          assert_equal 1, shopping_cart.reservations.count
          reservation = shopping_cart.reservations.first
          assert_equal @transactable.id, reservation.transactable.id
          assert_equal 'inactive', reservation.state
          assert_equal 'My cust value', reservation.properties.res_custom_attr
          assert_equal 3025, reservation.total_amount_cents.to_i
          assert_equal 2_75, reservation.service_fee_amount_guest_cents.to_i
          assert_equal 2_75, reservation.service_fee_amount_host_cents.to_i
          assert_equal 1, shopping_cart.reservations.first.periods.count
          assert_equal date, reservation.periods.first.date
          assert_equal start_minute, reservation.periods.first.start_minute
          assert_equal 865, reservation.periods.first.end_minute
          assert_no_difference 'ShoppingCart.count' do
            assert_no_difference 'Reservation.count' do
              assert_no_difference 'ReservationPeriod.count' do
                post :update, form_configuration_id: form_configuration.id,
                              form: {
                                orders: {
                                  :"#{@reservation_type.parameterized_name}" => {
                                    reservations_attributes: {
                                      '0' => {
                                        id: reservation.id,
                                        booking_type: 'hourly',
                                        transactable_id: @transactable.id,
                                        transactable_pricing_id: @transactable.action_type.hour_pricings.first.id,
                                        periods_attributes: {
                                          '0' => {
                                            id: reservation.periods.first.id,
                                            date: date.strftime('%Y-%m-%d'),
                                            start_minute: start_minute,
                                            hours: 2.5
                                          }
                                        },
                                        properties: {
                                          res_custom_attr: 'My cust value'
                                        }
                                      }
                                    }
                                  }
                                }
                              }
              end
            end
          end
          shopping_cart = @user.reload.current_shopping_cart
          refute shopping_cart.checkout_at
          reservation = shopping_cart.reservations.first
          assert_equal @transactable.id, reservation.transactable.id
          assert_equal 'inactive', reservation.state
          assert_equal 'My cust value', reservation.properties.res_custom_attr
          assert_equal 27_50, reservation.total_amount_cents.to_i
          assert_equal 250, reservation.service_fee_amount_guest_cents.to_i
          assert_equal 250, reservation.service_fee_amount_host_cents.to_i
          assert_equal date, reservation.periods.first.date
          assert_equal start_minute, reservation.periods.first.start_minute
          assert_equal 850, reservation.periods.first.end_minute
        end

        should 'display validation error message if not enough hours' do
          @page = FactoryGirl.create(:page)
          assert_no_difference 'ReservationPeriod.count' do
            post :create, form_configuration_id: form_configuration.id,
                          page_id: @page.id,
                          form: {
                            orders: {
                              :"#{@reservation_type.parameterized_name}" => {
                                reservations_attributes: {
                                  '0' => {
                                    booking_type: 'hourly',
                                    transactable_id: @transactable.id,
                                    transactable_pricing_id: @transactable.action_type.hour_pricings.first.id,
                                    periods_attributes: {
                                      '0' => {
                                        date: (Date.current + 2.days).strftime('%Y-%m-%d'),
                                        start_minute: 540,
                                        hours: 0.5
                                      }
                                    },
                                    properties: {
                                      res_custom_attr: 'My cust value'
                                    }
                                  }
                                }
                              }
                            }
                          }
          end
          assert_equal ["must be at least 1.5 hours"], assigns(:shopping_cart_form).errors[:"orders.#{@reservation_type.parameterized_name}.reservations.periods.hours"]
        end

        protected

        def form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'shopping_cart_form',
            base_form: 'ShoppingCartForm',
            configuration: {
              orders: {
                :"#{@reservation_type.parameterized_name}" => {
                  reservations: {
                    validation: {
                      presence: true
                    },
                    periods: {
                      start_minute: {
                        validation: {
                          presence: true
                        },
                        property_options: {
                          default: 540
                        }
                      },
                      hours: {
                        validation: {
                          presence: true
                        }
                      },
                      validate_minimum_booking_hours: true
                    },
                    properties: {
                      validation: {
                        presence: true
                      },
                      res_custom_attr: {
                        validation: {
                          presence: true
                        }
                      }
                    }
                  }
                }
              }
            }
          )
        end
      end
    end
  end
end
