# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    class UsersControllerTest < ActionController::TestCase
      setup do
        @user = FactoryGirl.create(:user)
        @form_configuration = FormConfiguration.create!(
          name: 'Signup',
          base_form: 'UserSignup::DefaultUserSignup',
          configuration: {
            name: {
              validation: { presence: {} }
            }
          }
        )
      end

      context 'default user' do # rubocop:disable Metrics/BlockLength
        context 'create' do # rubocop:disable Metrics/BlockLength
          should 'successfully sign up without extra configuration' do
            assert_difference('User.count') do
              assert_difference('UserProfile.count') do
                post :create, form: user_attributes
              end
            end
          end

          context 'extra configuration' do # rubocop:disable Metrics/BlockLength
            context 'default profile' do
              setup do
                FactoryGirl.create(:user_custom_attribute, name: 'user_attr')
                @form_configuration.update_attributes(
                  configuration: {
                    name: {
                      validation: { presence: {} }
                    },
                    default_profile: {
                      properties: {
                        user_attr: { validation: { presence: true } }
                      }
                    }
                  }
                )
              end

              should 'not create user without required custom attribute' do
                assert_no_difference('User.count') do
                  assert_no_difference('UserProfile.count') do
                    post :create, form: user_attributes.merge(default_profile_attributes: { properties: {} })
                  end
                end
              end

              should 'create user when all params sent' do
                assert_difference('User.count') do
                  assert_difference('UserProfile.count') do
                    post :create, form: user_attributes.merge(default_profile_attributes: { properties: { user_attr: 'my value' } })
                  end
                end
                assert_equal 'my value', User.last.default_profile.properties.user_attr
              end
            end
          end
        end
      end

      context 'lister user' do # rubocop:disable Metrics/BlockLength
        context 'create' do # rubocop:disable Metrics/BlockLength
          setup do
            @form_configuration.update_attributes(
              base_form: 'UserSignup::ListerUserSignup',
              configuration: {
                name: {
                  validation: { presence: {} }
                },
                seller_profile: {
                  properties: {}
                },
                default_profile: {
                  properties: {}
                }
              }
            )
          end
          should 'successfully sign up without extra configuration' do
            assert_difference('User.count') do
              assert_difference('UserProfile.count', 2) do
                post :create, role: FormBuilder::UserSignupBuilderFactory::LISTER, form: user_attributes
              end
            end
          end

          context 'extra configuration' do # rubocop:disable Metrics/BlockLength
            context 'lister profile' do # rubocop:disable Metrics/BlockLength
              setup do
                FactoryGirl.create(:user_custom_attribute, name: 'user_attr')
                FactoryGirl.create(:user_custom_attribute, target: InstanceProfileType.seller.first, name: 'lister_attr')
                @form_configuration.update_attributes(
                  base_form: 'UserSignup::ListerUserSignup',
                  configuration: {
                    name: {
                      validation: { presence: {} }
                    },
                    seller_profile: {
                      properties: {
                        lister_attr: { validation: { presence: true } }
                      }
                    },
                    default_profile: {
                      properties: {
                        user_attr: { validation: { presence: true } }
                      }
                    }
                  }
                )
              end

              should 'not create user without required custom attribute' do
                assert_no_difference('User.count') do
                  assert_no_difference('UserProfile.count') do
                    post :create, role: FormBuilder::UserSignupBuilderFactory::LISTER, form: user_attributes.merge(default_profile_attributes: { properties: {} },
                                                                                                                   seller_profile_attributes: { properties: {} })
                    assert_equal ['can\'t be blank'], assigns(:user_signup).errors[:'default_profile.properties.user_attr']
                    assert_equal ['can\'t be blank'], assigns(:user_signup).errors[:'seller_profile.properties.lister_attr']
                  end
                end
              end

              should 'create user when all params sent' do
                assert_difference('User.count') do
                  assert_difference('UserProfile.count', 2) do
                    post :create, role: FormBuilder::UserSignupBuilderFactory::LISTER,
                                  form: user_attributes.merge(
                                    default_profile_attributes: { properties: { user_attr: 'my value' } },
                                    seller_profile_attributes: { properties: { lister_attr: 'other value' } }
                                  )
                  end
                end
                assert_equal 'other value', User.last.seller_profile.properties.lister_attr
                assert_equal 'my value', User.last.default_profile.properties.user_attr
              end
            end
          end
        end
      end

      context 'enquirer user' do # rubocop:disable Metrics/BlockLength
        context 'create' do # rubocop:disable Metrics/BlockLength
          setup do
            @form_configuration.update_attributes(
              base_form: 'UserSignup::EnquirerUserSignup',
              configuration: {
                name: {
                  validation: { presence: {} }
                },
                buyer_profile: {
                  properties: {}
                },
                default_profile: {
                  properties: {}
                }
              }
            )
          end

          context 'extra configuration' do # rubocop:disable Metrics/BlockLength
            context 'enquirer profile' do # rubocop:disable Metrics/BlockLength
              setup do
                FactoryGirl.create(:user_custom_attribute, name: 'user_attr')
                FactoryGirl.create(:user_custom_attribute, target: InstanceProfileType.buyer.first, name: 'enquirer_attr')
                @form_configuration.update_attributes(
                  base_form: 'UserSignup::EnquirerUserSignup',
                  configuration: {
                    name: {
                      validation: { presence: {} }
                    },
                    buyer_profile: {
                      properties: {
                        enquirer_attr: { validation: { presence: true } }
                      }
                    },
                    default_profile: {
                      properties: {
                        user_attr: { validation: { presence: true } }
                      }
                    }
                  }
                )
              end

              should 'not create user without required custom attribute' do
                assert_no_difference('User.count') do
                  assert_no_difference('UserProfile.count') do
                    post :create, role: FormBuilder::UserSignupBuilderFactory::ENQUIRER, form: user_attributes
                      .merge(default_profile_attributes: { properties: {} },
                             buyer_profile_attributes: { properties: {} })
                    assert_equal ['can\'t be blank'], assigns(:user_signup).errors[:'default_profile.properties.user_attr']
                    assert_equal ['can\'t be blank'], assigns(:user_signup).errors[:'buyer_profile.properties.enquirer_attr']
                  end
                end
              end

              should 'create user when all params sent' do
                assert_difference('User.count') do
                  assert_difference('UserProfile.count', 2) do
                    post :create, role: FormBuilder::UserSignupBuilderFactory::ENQUIRER,
                                  form: user_attributes.merge(
                                    default_profile_attributes: { properties: { user_attr: 'my value' } },
                                    buyer_profile_attributes: { properties: { enquirer_attr: 'other value' } }
                                  )
                  end
                end
                assert_equal 'my value', User.last.default_profile.properties.user_attr
                assert_equal 'other value', User.last.buyer_profile.properties.enquirer_attr
              end
            end
          end
        end
      end

      context 'verify' do
        should 'verify user if token and id are correct' do
          get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token
          assert @user.reload.verified_at.present?
          assert_redirected_to root_path
        end

        should 'handle situation when user is verified' do
          @time = Time.zone.now
          @user.update_attribute(:verified_at, @time)
          get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token
          assert_equal @time.to_i, @user.reload.verified_at.to_i
          assert_response 200
        end

        should 'not verify user if id is incorrect' do
          assert_raise ActiveRecord::RecordNotFound do
            get :verify, id: (@user.id + 1), token: UserVerificationForm.new(@user).email_verification_token
          end
        end

        should 'not verify user if token is incorrect' do
          get :verify, id: @user.id, token: 'incorrect'
          assert_nil @user.reload.verified_at
          assert_response 200
        end
      end

      protected

      def user_attributes
        { name: 'Test User', email: 'user@example.com', password: 'secret' }
      end
    end
  end
end
