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

      pricing = @transactable_type.offer_action.pricings.first_or_initialize
      pricing.attributes = {
        unit: 'hour',
        number_of_units: 1,
        order_class_name: 'Offer',
        allow_free_booking: false,
        allow_nil_price_cents: true
      }

      @transactable_type.save!
      pricing.save!
    end

    def set_theme_options
      theme = @instance.theme

      theme.color_green = '#4fc6e1'
      theme.color_blue = '#05caf9'
      theme.color_red = '#e83d33'
      theme.color_orange = '#ff8d00'
      theme.color_gray = '#394449'
      theme.color_black = '#1e2222'
      theme.color_white = '#fafafa'
      theme.call_to_action = 'Learn more'

      theme.phone_number = '1-888-893-0705'
      theme.contact_email = 'info@UpsideOfTalent.com'
      theme.support_email = 'info@UpsideOfTalent.com'

      theme.facebook_url = 'https://www.facebook.com/UpsideOfTalent'
      theme.twitter_url = 'https://twitter.com/UpsideOfTalent'
      theme.gplus_url = 'https://plus.google.com/102635346315218116617'
      theme.instagram_url = 'https://www.instagram.com'
      theme.youtube_url = 'https://www.youtube.com/channel/UChQrYDFiI79ViMy98FeulkQ'
      theme.blog_url = '/blog'
      theme.linkedin_url = 'https://www.linkedin.com/company/upside-of-talent-llc'

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
