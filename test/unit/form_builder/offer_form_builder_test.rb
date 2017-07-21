# frozen_string_literal: true
require 'test_helper'

class OfferFormBuilderTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @transactable = FactoryGirl.create(:transactable_offer, creator: @user)
    @pricing = @transactable.action_type.pricings.first
    @reservation_type = FactoryGirl.create(:reservation_type)
    @custom_model_type = FactoryGirl.create(:custom_model_type_offer_files, reservation_types: Array.wrap(@reservation_type))
    @reservation_type.reload
  end

  should 'return errors' do
    offer_form = form(default_config)
    params = default_params
    params['customizations'].delete('offer_files_attributes')
    refute offer_form.validate(params), offer_form.errors.messages
  end

  should 'create new offer' do
    offer_form = form(default_config)
    assert offer_form.validate(default_params), offer_form.errors.messages
    assert_difference 'Offer.count', 1 do
      offer_form.save
    end
    assert offer_form.model.persisted?
    assert_equal 'unconfirmed', offer_form.model.state
    assert_equal 1, offer_form.model.customizations.count
    assert_equal 1 , offer_form.model.customizations.find_by(custom_model_type: @custom_model_type).custom_attachments.count
    assert_equal 'foobear.jpeg' , offer_form.model.customizations.find_by(custom_model_type: @custom_model_type).custom_attachments.first[:file]
  end

  def default_params
    {
      transactable_pricing_id: @transactable.action_type.pricings.first.id,
      transactable_id: @transactable.id,
      reservation_type_id: @reservation_type.id,
      'customizations' => {
        'offer_files_attributes' => {
          '0' => {
            custom_attachments: {
              offer_file: {
                file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
              }
            }
          }
        }
      }
    }
  end

  def default_config
    {
      state_event: {
        property_options: {
          default: 'activate',
          readonly: true
        }
      },
      customizations: {
        validation: {
          presence: true
        },
        offer_files: {
          validation: {
            presence: true
          },
          custom_attachments: {
            offer_file: {
              validation: {
                presence: true
              },
              file: {
                validation: {
                  presence: true
                }
              }
            }
          }
        }
      }
    }
  end

  def form(config)
    FormBuilder.new(
      base_form: OfferForm,
      configuration: config,
      object: @pricing.order_class.new(user: @user, reservation_type: @reservation_type)
    ).build
  end
end
