require 'yaml'

# frozen_string_literal: true
namespace :localdriva do
  desc 'Setup LocalDriva'
  task setup: :environment do
    @instance = Instance.find(211)
    @instance.set_context!
    @instance.build_availability_templates
    @instance.save!

    setup = LocaldrivaSetup.new(@instance, File.join(Rails.root, 'lib', 'tasks', 'localdriva'))
    setup.create_offer_action
    setup.set_theme_options
    setup.cleanup_workflow_alerts
  end

  class LocaldrivaSetup
    def initialize(instance, theme_path)
      @instance = instance
      @instance.set_context!
      @theme_path = theme_path
    end

    def create_offer_action
      @transactable_type = TransactableType.find_by(name: 'Booking')
      @transactable_type.time_based_booking = nil

      @transactable_type.offer_action ||= @transactable_type.build_offer_action(
        enabled: true,
        cancellation_policy_enabled: '1',
        cancellation_policy_hours_for_cancellation: 24,
        cancellation_policy_penalty_hours: 1.5,
        service_fee_guest_percent: 0,
        service_fee_host_percent: 10
      )

      @transactable_type.save!

      if @transactable_type.offer_action.pricings.count == 1
        pricing = @transactable_type.offer_action.pricings.first
        pricing.attributes = {
          unit: 'hour',
          number_of_units: 1,
          order_class_name: 'Offer',
          allow_free_booking: false,
          allow_nil_price_cents: true,
          fixed_price_cents: 50_00
        }
        pricing.save!
      end

      pricing = @transactable_type.offer_action.pricings.where(fixed_price_cents: 50_00).first_or_initialize
      pricing.attributes = {
        unit: 'hour',
        number_of_units: 1,
        order_class_name: 'Offer',
        allow_free_booking: false,
        allow_nil_price_cents: true,
        fixed_price_cents: 50_00
      }
      pricing.save!

      pricing = @transactable_type.offer_action.pricings.where(fixed_price_cents: 100_00).first_or_initialize
      pricing.attributes = {
        unit: 'hour',
        number_of_units: 2,
        order_class_name: 'Offer',
        allow_free_booking: false,
        allow_nil_price_cents: true,
        fixed_price_cents: 100_00
      }
      pricing.save!

      pricing = @transactable_type.offer_action.pricings.where(fixed_price_cents: 150_00).first_or_initialize
      pricing.attributes = {
        unit: 'hour',
        number_of_units: 3,
        order_class_name: 'Offer',
        allow_free_booking: false,
        allow_nil_price_cents: true,
        fixed_price_cents: 150_00
      }
      pricing.save!
    end

    def set_theme_options
      theme = @instance.theme

      theme.color_green = '#f05b64'
      theme.color_blue = '#f05b64'

      # theme.remote_favicon_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2760/favicon.png'
      # theme.remote_icon_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2761/apple-touch-icon-60_2x.png'

      theme.updated_at = Time.now
      theme.save!
    end

    def cleanup_workflow_alerts
      Workflow.where(workflow_type: 'offer').destroy_all
      Workflow.where(workflow_type: %w(request_for_quote reservation recurring_booking inquiry spam_report)).destroy_all
      WorkflowAlert.where(alert_type: 'sms').destroy_all
      alerts_to_be_destroyed = ['offer_mailer/notify_host_of_rejection']
      WorkflowAlert.where(template_path: alerts_to_be_destroyed).destroy_all
    end
  end
end
