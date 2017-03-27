# frozen_string_literal: true
class SecuredParams
  def shipping_profile
    [
      :name,
      shipping_rules_attributes: nested(shipping_rule)
    ]
  end

  def shipping_provider
    [
      :shipping_provider_name,
      settings: [:api_key, :sendle_id, :environment]
    ]
  end

  def dimensions_template
    [
      :name,
      :unit_of_measure,
      :weight,
      :height,
      :width,
      :depth,
      :weight_unit,
      :height_unit,
      :width_unit,
      :depth_unit,
      :use_as_default
    ]
  end

  def bank_account
    [
      :verification_amount_1,
      :verification_amount_2
    ]
  end

  def custom_attribute
    [
      :name,
      :attribute_type,
      :html_tag,
      :prompt,
      :required,
      :min_length,
      :max_length,
      :min_value,
      :max_value,
      :step,
      :default_value,
      :public,
      :label,
      :placeholder,
      :hint,
      :searchable,
      :search_in_query,
      :aggregate_in_search,
      :input_html_options,
      :wrapper_html_options,
      :input_html_options_string,
      :wrapper_html_options_string,
      :validation_only_on_update,
      :aggregate_in_search,
      custom_validators_attributes: nested(custom_validator),
      valid_values: []
    ]
  end

  def custom_validator
    [
      :field_name,
      :required,
      :min_length,
      :max_length,
      :valid_values,
      :validatable_type,
      :validation_only_on_update,
      :regex_validation,
      :regex_expression
    ]
  end

  def data_upload
    [
      :csv_file,
      options: [:send_invitational_email, :sync_mode, :enable_rfq, :default_shipping_category_id]
    ]
  end

  def instance_admin_role
    [
      :permission_analytics,
      :permission_settings,
      :permission_theme,
      :permission_transfers,
      :permission_inventories,
      :permission_partners,
      :permission_users,
      :permission_pages,
      :permission_manage,
      :permission_blog,
      :permission_support,
      :permission_buysell,
      :name
    ]
  end

  def shipping_category
    [
      :name
    ]
  end

  def shipping_method
    [
      :name,
      :tax_category_id,
      shipping_category_ids: [],
      zone_ids: []
    ]
  end

  def calculator
    [
      :preferred_amount
    ]
  end

  def tax_category
    [
      :name,
      :description,
      :is_default
    ]
  end

  def tax_region
    [
      :country_id,
      tax_rates_attributes: nested(tax_rate)
    ]
  end

  def tax_rate
    [
      :id,
      :name,
      :admin_name,
      :value,
      :included_in_price,
      :calculate_with,
      :default,
      :state_id
    ]
  end

  def zone
    [
      :name,
      :description,
      :default_tax,
      :kind,
      :country_ids,
      :state_ids,
      state_ids: [],
      country_ids: []
    ]
  end

  def custom_model_type
    [
      :name,
      transactable_type_ids: [],
      project_type_ids: [],
      reservation_type_ids: [],
      instance_profile_type_ids: []
    ]
  end

  def category
    [
      :name,
      :parent_id,
      :child_index,
      :multiple_root_categories,
      :search_options,
      :display_options,
      :mandatory,
      transactable_type_ids: [],
      project_type_ids: [],
      instance_profile_type_ids: [],
      reservation_type_ids: []
    ]
  end

  def email_template
    [
      :body,
      :path,
      :format,
      locale_ids: [],
      transactable_type_ids: []
    ]
  end

  def liquid_view
    [
      :body,
      :path,
      :partial,
      :draft,
      locale_ids: [],
      transactable_type_ids: []
    ]
  end

  def email_layout_template
    [
      :body,
      :path,
      :format,
      locale_ids: [],
      transactable_type_ids: []
    ]
  end

  def sms_template
    [
      :body,
      :path,
      locale_ids: [],
      transactable_type_ids: []
    ]
  end

  def blog_instance
    [
      :enabled,
      :allow_video_embeds,
      :name,
      :header,
      :facebook_app_id,
      :header_text,
      :header_motto,
      :header_logo,
      :header_icon,
      owner_attributes: nested([:user_blogs_enabled, :enquirer_blogs_enabled, :lister_blogs_enabled])
    ]
  end

  def default_image
    [
      :photo_uploader,
      :photo_uploader_version
    ]
  end

  def blog_post
    [
      :title,
      :content,
      :excerpt,
      :published_at,
      :slug,
      :header,
      :author_name,
      :author_biography,
      :author_avatar,
      :tag_list
    ]
  end

  def user_blog
    [
      :enabled,
      :name,
      :header_image,
      :header_text,
      :header_motto,
      :header_logo,
      :header_icon,
      :facebook_app_id
    ]
  end

  def user_blog_post
    [
      :title,
      :published_at_str,
      :slug,
      :hero_image,
      :content,
      :excerpt,
      :author_name,
      :author_biography,
      :author_avatar_img,
      :logo,
      :tag_list
    ]
  end

  def admin_user_blog_post
    user_blog_post + [:highlighted]
  end

  def instance
    [
      :apply_text_filters,
      :bookable_noun,
      :categories,
      :db_connection_string,
      :default_country,
      :default_currency,
      :default_oauth_signin_provider,
      :default_products_search_view,
      :enable_geo_localization,
      :expand_orders_list,
      :facebook_consumer_key,
      :facebook_consumer_secret,
      :google_consumer_key,
      :google_consumer_secret,
      :github_consumer_key,
      :github_consumer_secret,
      :force_accepting_tos,
      :instagram_consumer_key,
      :instagram_consumer_secret,
      :instance_billing_gateways_attributes,
      :last_index_job_id,
      :linkedin_consumer_key,
      :linkedin_consumer_secret,
      :mark_as_locked,
      :marketplace_password,
      :name,
      :olark_api_key,
      :olark_enabled,
      :onboarding_verification_required,
      :password_protected,
      :payment_transfers_frequency,
      :paypal_email,
      :require_payout_information,
      :search_settings,
      :service_fee_guest_percent,
      :service_fee_host_percent,
      :shippo_api_token,
      :skip_company,
      :stripe_currency,
      :support_email,
      :support_imap_password,
      :support_imap_port,
      :support_imap_server,
      :support_imap_ssl,
      :support_imap_username,
      :taxonomy_tree,
      :tax_included_in_price,
      :test_balanced_api_key,
      :test_email,
      :test_mode,
      :test_twilio_consumer_key,
      :test_twilio_consumer_secret,
      :test_twilio_from_number,
      :time_zone,
      :tt_select_type,
      :twilio_consumer_key,
      :twilio_consumer_secret,
      :twilio_from_number,
      :twilio_ring_tone,
      :twitter_consumer_key,
      :twitter_consumer_secret,
      :use_cart,
      :user_based_marketplace_views,
      :user_blogs_enabled,
      :webhook_token,
      :wish_lists_enabled,
      :wish_lists_icon_set,
      :custom_waiver_agreements,
      :seller_attachments_access_level,
      :seller_attachments_enabled,
      :enable_language_selector,
      :click_to_call,
      :skip_meta_tags,
      :enable_sms_and_api_workflow_alerts_on_staging,
      :show_currency_symbol,
      :show_currency_name,
      :no_cents_if_whole,
      :google_maps_api_key,
      :debugging_mode_for_admins,
      :timeout_in_minutes,
      :only_first_name_as_user_slug,
      allowed_currencies: [],
      allowed_countries: [],
      custom_translations: [:'buy_sell_market.checkout.manual_payment', :'buy_sell_market.checkout.manual_payment_description'],
      password_validation_rules: [:uppercase, :lowercase, :number, :symbol, :min_password_length],
      domains_attributes: nested(domain),
      location_types_attributes: nested(location_type),
      text_filters_attributes: nested(text_filter),
      transactable_types_attributes: nested(transactable_type),
      translations_attributes: nested(translation),
      theme_attributes: theme
    ]
  end

  def instance_profile_type
    [
      :searchable,
      :search_engine,
      :show_categories,
      :category_search_type,
      :position,
      :search_only_enabled_profiles,
      :onboarding,
      :default_availability_template_id,
      :must_have_verified_phone_number,
      :admin_approval,
      :create_company_on_sign_up,
      :default_sort_by,
      custom_attributes_attributes: [:searchable, :id]
    ]
  end

  def payment_document
    [
      :type,
      :file,
      :file_cache,
      :attachable_id,
      :attachable_type,
      :id,
      :user_id,
      payment_document_info_attributes: nested(payment_document_info)
    ]
  end

  def payment_document_info
    [
      :document_requirement_id,
      :attachment_id
    ]
  end

  def shipping_rule
    [
      :name,
      :processing_time,
      :price,
      :is_worldwide,
      :is_pickup,
      :use_shippo_for_price,
      country_ids: []
    ]
  end

  def availability_template
    [
      :transactable_type,
      :name, :description,
      :availability_rules,
      availability_rules_attributes: nested(availability_rule),
      schedule_exception_rules_attributes: nested(schedule_exception_rule)

    ]
  end

  def text_filter
    [
      :name,
      :regexp,
      :flags,
      :replacement_text
    ]
  end

  def transactable_type
    [
      :allow_save_search,
      :bookable_noun, :lessor, :lessee, :action_schedule_booking,
      :bookable_noun, :lessor, :lessee,
      :category_search_type,
      :default_search_view,
      :date_pickers_use_availability_rules,
      :date_pickers_mode,
      :default_currency,
      :default_availability_template_id,
      :enable_photo_required,
      :enable_reviews,
      :name,
      :show_page_enabled,
      :groupable_with_others,
      :skip_location,
      :rental_shipping,
      :show_company_name,
      :searchable,
      :search_engine,
      :searcher_type,
      :search_radius,
      :action_rfq,
      :search_placeholder,
      :show_categories,
      :timezone_rule,
      :show_price_slider,
      :search_price_types_filter,
      :search_location_type_filter,
      :show_date_pickers,
      :date_pickers_use_availability_rules,
      :date_pickers_mode,
      :show_path_format,
      :hide_additional_charges_on_listing_page,
      :single_location,
      :require_transactable_during_onboarding,
      availability_templates_attributes: nested(availability_template),
      allowed_currencies: [],
      merchant_fees_attributes: nested(charge_type),
      all_action_types_attributes: nested(transactable_type_action_type),
      custom_attributes_attributes: [:searchable, :id]
    ]
  end

  def transactable_type_action_type
    [
      :enabled,
      :hours_to_expiration,
      :minimum_booking_minutes,
      :service_fee_guest_percent, :service_fee_host_percent,
      :minimum_lister_service_fee,
      :favourable_pricing_rate,
      :cancellation_policy_enabled,
      :cancellation_policy_penalty_percentage,
      :cancellation_policy_hours_for_cancellation,
      :cancellation_policy_penalty_hours,
      :action_continuous_dates_booking,
      :allow_action_rfq,
      :allow_no_action,
      :allow_custom_pricings,
      :allow_drafts,
      :type,
      :hours_to_order_item_approval,
      :confirm_reservations,
      :send_alert_hours_before_expiry,
      :send_alert_hours_before_expiry_hours,
      :both_side_confirmation,
      pricings_attributes: nested(transactable_type_pricing),
      schedule_attributes: nested(schedule),
      availability_template_attributes: nested(availability_template)
    ]
  end

  def transactable_type_pricing
    [
      :id,
      :transactable_type_pricing_id,
      :min_price,
      :min_price_cents,
      :max_price,
      :max_price_cents,
      :number_of_units,
      :unit,
      :pro_rated,
      :allow_exclusive_price,
      :allow_book_it_out_discount,
      :allow_free_booking,
      :allow_nil_price_cents,
      :order_class_name,
      :fixed_price,
      :fixed_price_cents
    ]
 end

  def location_type
    [
      :name
    ]
  end

  def payment_gateway(payment_gateway_class)
    [
      :type,
      :live_active,
      :test_active,
      :payout_enabled,
      :immediate_payout_enabled,
      :payment_currency_ids,
      :payment_country_ids,
      :payout_currency_ids,
      :payout_country_ids,
      payment_currency_ids: [],
      payment_country_ids: [],
      payout_currency_ids: [],
      payout_country_ids: [],
      live_settings: payment_gateway_class.settings.keys,
      test_settings: payment_gateway_class.settings.keys,
      payment_methods_attributes: nested(payment_method),
      config: payment_gateway_config(payment_gateway_class.new.config_settings)
    ]
  end

  def payment_gateway_config(config_settings)
    config = []
    config_settings.each do |key, value|
      config << if value.instance_of?(Hash) && !value.key?(:valid_values)
                  [key => payment_gateway_config(value)]
                else
                  key
                end
    end

    config
  end

  def payment_method
    [
      :active,
      :type,
      :payment_method_type,
      :id,
      settings: PaymentMethod::AchPaymentMethod.settings.keys
    ]
  end

  def payment_source
    [
      :public_token,
      :account_id,
      :express_token,
      :payment_method_nonce,
      :email
    ]
  end

  def instance_admin_buy_sell_configuration
    [
      :currency,
      :currency_symbol_position,
      :currency_decimal_mark,
      :currency_thousands_separator
    ]
  end

  def translation
    [
      :key,
      :instance_id,
      :locale,
      :value
    ]
  end

  def page
    [
      :path,
      :content,
      :css_content,
      :hero_image,
      :slug,
      :position,
      :redirect_url,
      :redirect_code,
      :open_in_new_window,
      :layout_name,
      :metadata_title,
      :metadata_meta_description,
      :metadata_canonical_url
    ]
  end

  def instance_view
    [
      :body,
      :path,
      :format,
      :handler,
      :partial,
      locale_ids: [],
      transactable_type_ids: []
    ]
  end

  def partner
    [
      :name,
      :search_scope_option,
      domain_attributes: nested(domain),
      theme_attributes: theme
    ]
  end

  def custom_theme
    [
      :name,
      :in_use,
      :in_use_for_instance_admins,
      :copy_from_template,
      :overwrite_existing
    ]
  end

  def custom_theme_asset
    [
      :name,
      :body,
      :file,
      :type,
      :commment
    ]
  end

  def theme
    [
      :name,
      :site_name,
      :tagline,
      :meta_title,
      :description,
      :phone_number,
      :contact_email,
      :support_email,
      :address,
      :blog_url,
      :facebook_url,
      :twitter_url,
      :gplus_url,
      :instagram_url,
      :youtube_url,
      :linkedin_url,
      :rss_url,
      :color_blue,
      :color_red,
      :color_orange,
      :color_green,
      :color_gray,
      :color_black,
      :color_white,
      :homepage_css,
      :homepage_content,
      :call_to_action,
      :white_label_enabled,
      :support_url,
      theme_font_attributes: nested(theme_font)
    ]
  end

  def theme_font
    [
      :bold_eot, :bold_svg, :bold_ttf, :bold_woff,
      :medium_eot, :medium_svg, :medium_ttf, :medium_woff,
      :regular_eot, :regular_svg, :regular_ttf, :regular_woff
    ]
  end

  def support_faq
    [
      :question,
      :answer,
      :position
    ]
  end

  def support_ticket
    [
      messages_attributes: support_message
    ]
  end

  def support_ticket_message_attachment
    [
      :file, :tag, :file_cache
    ]
  end

  def guest_support_message
    [
      :message,
      attachment_ids: []
    ]
  end

  def support_message
    [
      :message,
      :subject,
      :full_name,
      :email,
      attachment_ids: []
    ]
  end

  def user_message
    [
      :body,
      :replying_to_id,
      attachments_attributes: nested(attachment)
    ]
  end

  def inquiry
    [
      :name,
      :company_name,
      :email
    ]
  end

  def comment
    [
      :body,
      :title,
      :creator_id,
      :report_as_spam,
      activity_feed_images_attributes: nested(activity_feed_image)
    ]
  end

  def company(transactable_type: nil)
    [
      :name,
      :url,
      :email,
      :description,
      :paypal_email,
      :bank_owner_name,
      :bank_routing_number,
      :bank_account_number,
      :white_label_enabled,
      :listings_public,
      locations_attributes: nested(location(transactable_type)),
      domain_attributes: nested(domain),
      approval_requests_attributes: nested(approval_request),
      company_address_attributes: nested(address),
      payments_mailing_address_attributes: nested(address),
      theme_attributes: theme
    ] << {
      shipping_profiles_attributes: nested(shipping_profile)
    }
  end

  def merchant_account(merchant_account)
    attributes = [:id, :redirect_url]
    attributes << merchant_account.class::ATTRIBUTES
    attributes << { payment_subscription_attributes: nested(payment_subscription) }
    attributes << { owners_attributes: merchant_account_owner }
    attributes
  end

  def merchant_account_owner
    attributes = [:id]
    attributes << [:document]
    attributes << { current_address_attributes: nested(address) }
    attributes << { attachements_attributes: nested(merchant_account_owner_attachement) }
    attributes << MerchantAccountOwner::StripeConnectMerchantAccountOwner::ATTRIBUTES
  end

  def merchant_account_owner_attachement
    [
      :file
    ]
  end

  def domain
    [
      :name,
      :target,
      :target_id,
      :target_type,
      :secured,
      :use_as_default,
      :white_label_enabled,
      :google_analytics_tracking_code,
      :certificate_body,
      :private_key,
      :certificate_chain,
      :redirect_to,
      :redirect_code,
      :uploaded_sitemap,
      :remove_uploaded_sitemap,
      :uploaded_robots_txt,
      :remove_uploaded_robots_txt,
      :aws_certificate_id
    ]
  end

  def aws_certificate
    [
      :name,
      :instance_id,
      :domain_id
    ]
  end

  def address
    [
      :address, :address2, :formatted_address, :postcode,
      :suburb, :city, :state, :country, :street, :should_check_address,
      :latitude, :local_geocoding, :longitude, :state_code, :raw_address,
      :state_id, :country_id,
      address_components: [:long_name, :short_name, :types]
    ]
  end

  def form_component
    [:form_type, :name]
  end

  def location(transactable_type = nil)
    [
      :description, :email, :info, :currency,
      :phone, :availability_template_id, :special_notes,
      :location_type_id, :photos,
      :administrator_id, :name, :location_address,
      :availability_template_id,
      :time_zone,
      availability_template_attributes: nested(availability_template),
      location_address_attributes: nested(address),
      listings_attributes: nested(transactable(transactable_type)),
      approval_requests_attributes: nested(approval_request),
      waiver_agreement_template_ids: []
    ] + address
  end

  def transactable(transactable_type, is_creator = false)
    base_params = [
      :name, :description, :capacity, :confirm_reservations,
      :location_id,
      :draft,
      :enabled,
      :deposit_amount,
      :quantity,
      :currency,
      :last_request_photos_sent_at, :activated_at, :rank,
      :transactable_type_id, :transactable_type,
      :insurance_value,
      :rental_shipping_type, :dimensions_template_id,
      :shipping_profile_id,
      :tag_list,
      :minimum_booking_minutes,
      :seek_collaborators,
      photos_attributes: nested(photo),
      approval_requests_attributes: nested(approval_request),
      photo_ids: [],
      category_ids: [],
      transactable_dimensions_template_attributes: [:dimensions_template_id],
      attachment_ids: [],
      waiver_agreement_template_ids: [],
      topic_ids: [],
      group_ids: [],
      action_types_attributes: nested(transactable_action_type),
      document_requirements_attributes: nested(document_requirement),
      upload_obligation_attributes: nested(upload_obligation),
      additional_charge_types_attributes: nested(additional_charge_type),
      customizations_attributes: nested(customization(transactable_type)),
      links_attributes: nested(link),
      properties_attributes: Transactable.public_custom_attributes_names((transactable_type || PlatformContext.current.try(:instance).try(:transactable_types).try(:first)).try(:id))
    ] +
                  Transactable.public_custom_attributes_names((transactable_type || PlatformContext.current.try(:instance).try(:transactable_types).try(:first)).try(:id))
    base_params += [new_collaborators: [:email, :id, :_destroy], new_collaborators_attributes: nested(transactable_collaborator)] if is_creator
    base_params
  end

  def transactable_action_type
    [
      :enabled,
      :type,
      :action_rfq,
      :no_action,
      :minimum_booking_minutes,
      :availability_template_id,
      :transactable_type_action_type_id,
      pricings_attributes: nested(transactable_pricing),
      schedule_attributes: nested(schedule),
      availability_template_attributes: nested(availability_template)
    ]
  end

  def transactable_pricing
    [
      :id,
      :transactable_type_pricing_id,
      :price,
      :price_cents,
      :number_of_units,
      :unit,
      :has_exclusive_price,
      :exclusive_price,
      :has_book_it_out_discount,
      :book_it_out_discount,
      :book_it_out_minimum_qty,
      :enabled,
      :is_free_booking,
      :currency
    ]
  end

  def transactable_for_instance_admin(transactable_type)
    transactable(transactable_type) + [
      :featured,
      properties: transactable_type.custom_attributes.pluck(&:name)
    ]
  end

  def customization(transactable_type)
    [
      :custom_model_type_id,
      custom_images_attributes: nested(custom_image),
      properties: transactable_type ? transactable_type.custom_model_types.map { |cmt| Customization.public_custom_attributes_names(cmt) }.flatten : [],
      properties_attributes: transactable_type ? transactable_type.custom_model_types.map { |cmt| Customization.public_custom_attributes_names(cmt) }.flatten : []
    ]
  end

  def project(transactable_type, is_project_owner = false)
    based_params = [
      :description,
      :transactable_type_id,
      :seek_collaborators,
      photos_attributes: nested(photo),
      links_attributes: nested(link),
      photo_ids: [],
      topic_ids: [],
      group_ids: [],
      properties_attributes: Transactable.public_custom_attributes_names((transactable_type || PlatformContext.current.try(:instance).try(:transactable_types).try(:first)).try(:id))
    ]
    based_params += [:name, new_collaborators: [:email, :id, :_destroy], new_collaborators_attributes: nested(transactable_collaborator)] if is_project_owner
    based_params
  end

  def group
    [
      :transactable_type_id,
      :name,
      :summary,
      :description,
      :cover_image,
      current_address_attributes: nested(address),
      cover_photo_attributes: nested(photo),
      photos_attributes: nested(photo),
      links_attributes: nested(link),
      photo_ids: [],
      new_group_members_attributes: nested(group_member),

      properties: [videos: []]
    ]
  end

  def reservation
    [
      :comment,
      periods_attributes: nested(period),
      additional_charges_attributes: nested(additional_charge)
    ]
  end

  def period
    [
      :date,
      :hours,
      :description
    ]
  end

  def reservation_type
    [
      :name,
      :step_checkout,
      :validate_on_adding_to_cart,
      :skip_payment_authorization,
      :check_overlapping_dates,
      :edit_unconfirmed,
      :withdraw_invitation_when_reject,
      transactable_type_ids: []
    ]
  end

  def transactable_collaborator
    [
      :approved,
      :approved_by_owner_at,
      :rejected_by_owner_at,
      :transactable_id,
      :user_id,
      :email
    ]
  end

  def group_member
    [
      :approved,
      :email,
      :moderator
    ]
  end

  def schedule
    [
      :schedule,
      :sr_start_datetime,
      :sr_from_hour,
      :sr_to_hour,
      :sr_every_hours,
      :use_simple_schedule,
      :unavailable_period_enabled,
      sr_days_of_week: [],
      schedule_rules_attributes: nested(schedule_rule),
      schedule_exception_rules_attributes: nested(schedule_exception_rule)
    ]
  end

  def schedule_exception_rule
    [
      :label,
      :duration_range_start,
      :duration_range_end,
      :user_duration_range_start,
      :user_duration_range_end
    ]
  end

  def schedule_rule
    [
      :run_hours_mode,
      :every_hours,
      :user_time_start,
      :user_time_end,
      :run_dates_mode,
      :user_date_start,
      :user_date_end,
      user_times: [],
      week_days: [],
      user_dates: []
    ]
  end

  def availability_rule
    [
      :day,
      :close_hour,
      :close_minute,
      :open_hour,
      :open_minute,
      :open_time,
      :close_time,
      days: []
    ]
  end

  def admin_approval_request
    [
      :state, :notes, :state_event
    ]
  end

  def approval_request
    [
      :message, :approval_request_template_id,
      :draft_at,
      approval_request_attachments_attributes: nested(approval_request_attachment)
    ]
  end

  def approval_request_template
    [
      :owner_type, :required_written_verification,
      approval_request_attachment_templates_attributes: nested(approval_request_attachment_template)
    ]
  end

  def approval_request_attachment_template
    [
      :label, :hint, :required
    ]
  end

  def approval_request_attachment
    [
      :approval_request_attachment_template_id,
      :caption,
      :file,
      :file_cache
    ]
  end

  def attachment
    [
      :file,
      :file_cache
    ]
  end

  def custom_image
    [
      :id,
      :image,
      :custom_attribute_id
    ]
  end

  def activity_feed_image
    [
      :id,
      :image
    ]
  end

  def photo
    [
      :id,
      :image,
      :caption,
      :position,
      :photo_role
    ]
  end

  def link
    [
      :_destroy,
      :id,
      :url,
      :text,
      :image,
      :image_cache
    ]
  end

  def user(transactable_type: nil, reservation_type: nil)
    [
      :avatar,
      :avatar_cache,
      :avatar_transformation_data,
      :avatar_versions_generated_at,
      :biography,
      :company_name,
      :country_name,
      :drivers_licence_number,
      :email,
      :first_name,
      :gender,
      :gov_number,
      :job_title,
      :language,
      :last_name,
      :middle_name,
      :mobile_number,
      :mobile_phone,
      :name,
      :password,
      :password_confirmation,
      :phone,
      :public_profile,
      :skills_and_interests,
      :skip_password,
      :sms_notifications_enabled,
      :accept_terms_of_service,
      :time_zone,
      :tag_list,
      category_ids: [],
      seller_profile_attributes: nested(seller_profile),
      buyer_profile_attributes: nested(buyer_profile),
      default_profile_attributes: nested(default_profile),
      current_address_attributes: nested(address),
      companies_attributes: nested(company(transactable_type: transactable_type)),
      approval_requests_attributes: nested(approval_request)
    ]
  end

  def user_from_instance_admin
    user + [
      :featured,
      default_profile_attributes: nested(default_profile_with_private_attribs)
    ]
  end

  def default_profile
    [
      :enabled,
      :instance_profile_type_id,
      properties: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id)),
      properties_attributes: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id)),
      category_ids: [],
      custom_images_attributes: nested(custom_image),
      customizations_attributes: nested(customization(PlatformContext.current.instance.default_profile_type))
    ]
  end

  def seller_profile
    [
      :enabled,
      :instance_profile_type_id,
      properties: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id)),
      properties_attributes: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id)),
      category_ids: [],
      customizations_attributes: nested(customization(PlatformContext.current.instance.seller_profile_type)),
      availability_template_attributes: nested(availability_template),
      custom_images_attributes: nested(custom_image)
    ]
  end

  def buyer_profile
    [
      :enabled,
      :instance_profile_type_id,
      properties: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id)),
      properties_attributes: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id)),
      category_ids: [],
      customizations_attributes: nested(customization(PlatformContext.current.instance.buyer_profile_type)),
      availability_template_attributes: nested(availability_template),
      custom_images_attributes: nested(custom_image)
    ]
  end

  def default_profile_with_private_attribs
    [
      properties: PlatformContext.current.instance.default_profile_type.custom_attributes.pluck(&:name),
      properties_attributes: PlatformContext.current.instance.default_profile_type.custom_attributes.pluck(&:name),
      category_ids: []
    ]
  end

  def seller
    UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id))
  end

  def buyer
    UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id))
  end

  def notification_preferences
    [
      :accept_emails,
      :sms_notifications_enabled,
      notification_preference_attributes: [
        :group_updates_enabled,
        :project_updates_enabled,
        :email_frequency
      ]
    ]
  end

  def click_to_call_preferences
    [
      :click_to_call
    ]
  end

  def workflow
    [
      :name
    ]
  end

  def topic
    [
      :about,
      :name,
      :description,
      :image,
      :cover_image,
      :featured,
      :category_id,
      data_source_attributes: nested(data_source)
    ]
  end

  def workflow_step
    [:name]
  end

  def workflow_alert(step_associated_class = nil)
    [
      :name,
      :alert_type,
      :recipient_type,
      :recipient,
      :template_path,
      :delay,
      :from,
      :from_type,
      :reply_to,
      :reply_to_type,
      :use_ssl,
      :request_type,
      :endpoint,
      :headers,
      :payload_data,
      :cc,
      :bcc,
      :bcc_type,
      :subject,
      :layout_path,
      :prevent_trigger_condition,
      :enabled
    ] + (step_associated_class.present? && defined?(step_associated_class.constantize::CUSTOM_OPTIONS) ? [custom_options: step_associated_class.constantize::CUSTOM_OPTIONS] : [])
  end

  def data_source
    [
      :type,
      settings: [:endpoint],
      fields: []
    ]
  end

  def waiver_agreement_template
    [
      :content,
      :name
    ]
  end

  def waiver_agreement
    []
  end

  def nested(object)
    object + [:id, :_destroy]
  end

  def rating_systems
    [
      rating_systems_attributes: rating_system
    ]
  end

  def rating_system
    [
      :id,
      :subject,
      :active,
      :transactable_type_id,
      rating_hints_attributes: nested(rating_hint),
      rating_questions_attributes: nested(rating_question)
    ]
  end

  def rating_hint
    [
      :id,
      :description
    ]
  end

  def rating_question
    [
      :id,
      :text
    ]
  end

  def reservation_request(reservation_type)
    [
      :quantity,
      :book_it_out,
      :exclusive_price,
      :start_minute,
      :start_time,
      :end_minute,
      :guest_notes,
      :payment_method_id,
      :booking_type,
      :delivery_type,
      :delivery_ids,
      :dates,
      :total_amount_check,
      :transactable_pricing_id,
      properties: Reservation.public_custom_attributes_names(reservation_type),
      properties_attributes: Reservation.public_custom_attributes_names(reservation_type),
      dates: [],
      category_ids: [],
      additional_charge_ids: [],
      waiver_agreement_templates: [],
      shipments_attributes: nested(shipment),
      payment_attributes: nested(payment),
      documents: nested(payment_document),
      documents_attributes: nested(payment_document),
      payment_subscription_attributes: nested(payment_subscription),
      payment_documents_attributes: nested(payment_document),
      owner_attributes: nested(user),
      address_attributes: nested(address)
    ]
  end

  def complete_reservation
    [
      :comment,
      transactable_line_items_attributes: nested(line_item),
      additional_line_items_attributes: nested(line_item)
    ]
  end

  def line_item
    [
      :quantity,
      :unit_price,
      :receiver,
      :name,
      :description
    ]
  end

  def order(reservation_type = nil)
    [
      :dates_fake,
      :interval,
      :start_on,
      :country_name,
      :mobile_number,
      :quantity,
      :book_it_out,
      :exclusive_price,
      :start_minute,
      :start_time,
      :end_minute,
      :guest_notes,
      :payment_method_id,
      :booking_type,
      :delivery_type,
      :delivery_ids,
      :inbound_pickup_date,
      :outbound_pickup_date,
      :outbound_return_address_address,
      :outbound_return_address_suburb,
      :outbound_return_address_postcode,
      :outbound_return_address_state,
      :outbound_return_address_country,
      :inbound_pickup_address_address,
      :inbound_pickup_address_suburb,
      :inbound_pickup_address_postcode,
      :inbound_pickup_address_state,
      :inbound_pickup_address_country,
      :inbound_sender_lastname,
      :outbound_receiver_lastname,
      :inbound_sender_firstname,
      :outbound_receiver_firstname,
      :inbound_sender_phone,
      :outbound_receiver_phone,
      :dates,
      :step_control,
      :total_amount_check,
      :transactable_pricing_id,
      :transactable_id,
      :use_billing,
      dates: [],
      category_ids: [],
      additional_charge_ids: [],
      waiver_agreement_templates: nested(waiver_agreement_templates),
      shipments_attributes: nested(shipment),
      documents: nested(payment_document),
      documents_attributes: nested(payment_document),
      payment_subscription_attributes: nested(payment_subscription),
      user_attributes: nested(user),
      address_attributes: nested(address),
      shipping_address_attributes: nested(order_address),
      billing_address_attributes: nested(order_address),
      payment_documents_attributes: nested(payment_document),
      payment_attributes: nested(payment),
      properties_attributes: Reservation.public_custom_attributes_names((reservation_type || PlatformContext.current.try(:instance).try(:reservation_type).try(:first)).try(:id))
    ]
  end

  def order_item # aka RecurringBookingPeriod
    [
      :comment,
      :rejection_reason,
      additional_line_items_attributes: nested(line_item),
      transactable_line_items_attributes: nested(line_item)
    ]
  end

  def waiver_agreement_templates
    WaiverAgreementTemplate.all.map { |w| w.id.to_s }
  end

  def payment
    [
      :payment_method_id,
      :payment_method_nonce,
      :chosen_credit_card_id,
      :payment_source_id,
      :credit_card_id,
      :bank_account_id,
      :payment_source_type,
      credit_card_attributes: nested(credit_card),
      payment_source_attributes: nested(payment_source)
    ]
  end

  def admin_paymnet
    [
      :exclude_from_payout
    ]
  end

  def payment_subscription
    [
      :payer_id,
      :payment_method_id,
      :credit_card_id,
      :bank_account_id,
      :payment_source_id,
      :payment_source_type,
      :chosen_credit_card_id,
      credit_card_attributes: nested(credit_card),
      payment_source_attributes: nested(payment_source)
    ]
  end

  def credit_card
    [
      :number,
      :verification_value,
      :month,
      :year,
      :first_name,
      :last_name,
      :credit_card_token
    ]
  end

  def review
    [
      :rating,
      :comment,
      :date,
      :transactable_type_id,
      :reviewable_id,
      :reviewable_type,
      :user_id
    ]
  end

  def rating_answers
    [
      rating_answers: rating_answer
    ]
  end

  def rating_answer
    [
      :id,
      :rating,
      :rating_question_id
    ]
  end

  def additional_charge
    [
      :id,
      :name,
      :description,
      :amount,
      :currency,
      :commission_receiver,
      :status,
      :selected,
      :instance_id,
      :additional_charge_type_target,
      :additional_charge_type_id,
      :_destroy
    ]
  end

  def additional_charge_type
    charge_type
  end

  def charge_type
    [
      :id,
      :name,
      :description,
      :amount,
      :percent,
      :currency,
      :commission_receiver,
      :status,
      :instance_id,
      :additional_charge_type_target
    ]
  end

  def documents_upload
    [
      :requirement,
      :enabled
    ]
  end

  def document_requirement
    [
      :label,
      :description,
      :hidden,
      :removed
    ]
  end

  def upload_obligation
    [:level]
  end

  def content_holder
    [
      :name,
      :content,
      :enabled,
      :position,
      inject_pages: []
    ]
  end

  def locale
    [
      :code,
      :custom_name,
      :primary
    ]
  end

  def saved_search
    [
      :title,
      :query
    ]
  end

  def shipment
    [
      :is_insured,
      :direction,
      :shippo_rate_id,
      :shipping_rule_id,
      shipping_address_attributes: order_address
    ]
  end

  def order_address
    [
      :user_id,
      :user_id,
      :shippo_id,
      :firstname,
      :lastname,
      :company,
      :state_id,
      :country_id,
      :street1,
      :street2,
      :city,
      :zip,
      :state,
      :phone,
      :email,
      :country,
      address_attributes: nested(address)
    ]
  end

  def user_status_update
    [
      :text,
      :user_id,
      :instance_id,
      :topic_ids,
      :updateable_id,
      :updateable_type,
      activity_feed_images_attributes: nested(activity_feed_image)
    ]
  end

  def photo_upload_version
    [
      :apply_transform,
      :width,
      :height,
      :photo_uploader,
      :version_name
    ]
  end

  def seller_attachment(instance)
    allowed = [:title]
    allowed << :access_level if instance.seller_attachments_access_sellers_preference?
    allowed
  end

  def help_content
    [
      :content
    ]
  end
end
