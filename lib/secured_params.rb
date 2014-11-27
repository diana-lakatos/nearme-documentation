class SecuredParams
  def custom_attribute
    [ :name,
      :attribute_type
    ] + self.custom_attribute_internal
  end

  def custom_attribute_internal
    [
      :html_tag,
      :prompt,
      :default_value,
      :public,
      :label,
      :placeholder,
      :hint,
      :input_html_options,
      :wrapper_html_options,
      :input_html_options_string,
      :wrapper_html_options_string,
      valid_values: []
    ]
  end

  def data_upload
    [
      :csv_file,
      options: nested([:send_invitational_email, :sync_mode])
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

  def tax_rate
    [
      :name,
      :amount,
      :included_in_price,
      :zone_id,
      :tax_category_id,
      :calculator_type
    ]
  end

  def zone
    [
      :name,
      :description,
      :default_tax,
      :kind,
      state_ids: [],
      country_ids: []
    ]
  end

  def taxonomy
    [
      :name
    ]
  end

  def taxon
    [
      :name,
      :in_top_nav,
      :top_nav_position
    ]
  end

  def search_notification
    [
      :email,
      :latitude,
      :longitude,
      :query
    ]
  end

  def email_template
    [
      :handler,
      :html_body,
      :text_body,
      :path,
      :partial,
      :subject,
      :to,
      :from,
      :bcc,
      :reply_to,
    ]
  end

  def blog_instance
    [
      :enabled,
      :name,
      :header,
      :facebook_app_id,
      :header_text,
      :header_motto,
      :header_logo,
      :header_icon
    ]
  end

  def blog_post
    [
      :title,
      :content,
      :exceprt,
      :published_at,
      :slug,
      :author_name,
      :author_biography,
      :author_avatar
    ]
  end

  def instance
    [
      :name,
      :service_fee_guest_percent, :service_fee_host_percent,
      :bookable_noun, :lessor, :lessee,
      :skip_company, :mark_as_locked,
      :live_stripe_api_key, :live_stripe_public_key,
      :live_paypal_username, :live_paypal_password,
      :live_paypal_signature, :live_paypal_app_id,
      :live_paypal_client_id,  :live_paypal_client_secret,
      :live_balanced_api_key,  :instance_billing_gateways_attributes,
      :test_stripe_api_key, :test_stripe_public_key,
      :test_paypal_username, :test_paypal_password,
      :test_paypal_signature, :test_paypal_app_id,
      :test_paypal_client_id, :test_paypal_client_secret,
      :test_balanced_api_key,
      :marketplace_password, :password_protected, :test_mode,
      :olark_api_key, :olark_enabled,
      :facebook_consumer_key, :facebook_consumer_secret,
      :twitter_consumer_key, :twitter_consumer_secret,
      :linkedin_consumer_key, :linkedin_consumer_secret,
      :instagram_consumer_key, :instagram_consumer_secret,
      :support_imap_hash, :support_email,
      :paypal_email, :db_connection_string,
      :stripe_currency, :user_info_in_onboarding_flow,
      :default_search_view, :user_based_marketplace_views,
      :searcher_type, :onboarding_verification_required,
      :apply_text_filters, :force_accepting_tos,
      user_required_fields: [],
      transactable_types_attributes: nested(self.transactable_type),
      listing_amenity_types_attributes: nested(self.amenity_type),
      location_amenity_types_attributes: nested(self.amenity_type),
      location_types_attributes: nested(self.location_type),
      instance_payment_gateways_attributes: nested(self.instance_payment_gateway),
      translations_attributes: nested(self.translation),
      domains_attributes: nested(self.domain),
      text_filters_attributes: nested(self.text_filter),
      theme_attributes: self.theme
    ]
  end

  def spree_image
    [
      :attachment,
      :viewable_id,
      :alt,
      :image,
      :product_id
    ]
  end

  def spree_option_type
    [
      :name,
      :presentation,
      :position,
      option_values_attributes: nested(self.spree_option_value),

    ]
  end

  def spree_option_value
    [
      :name,
      :presentation,
      :position
    ]
  end

  def spree_property
    [
      :name,
      :presentation,
      :position
    ]
  end

  def spree_product_property
    [
      :id,
      :property_name,
      :value,
      :company_id
    ]
  end

  def spree_variant
    [
      :sku,
      :price,
      :cost_price,
      :weight,
      :height,
      :depth,
      :tax_category_id,
      option_value_ids: []
    ]
  end

  def spree_prototype
    [
      :name,
      property_ids: [],
      option_type_ids: []
    ]
  end

  def spree_shipping_category
    [
      :name
    ]
  end

  def spree_shipping_method
    [
      :name,
      :admin_name,
      :display_on,
      :deleted_at,
      :tracking_url,
      :tax_category_id,
      shipping_category_ids: [],
      zone_ids: []
    ]
  end

  def spree_stock_location
    [
      :name,
      :admin_name,
      :address1,
      :address2,
      :city,
      :state_id,
      :state_name,
      :country_id,
      :zipcode,
      :phone,
      :active,
      :backorderable_default,
      :propagate_all_variants
    ]
  end

  def spree_stock_movement
    [
      :quantity
    ]
  end

  def availability_template
    [
      :transactable_type,
      :name, :description,
      :availability_rules,
      :availability_rules_attributes => nested(self.availability_rule)
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
      :name,
      :pricing_options,
      :pricing_validation,
      :availability_options,
      :favourable_pricing_rate,
      :cancellation_policy_enabled,
      :cancellation_policy_penalty_percentage,
      :cancellation_policy_hours_for_cancellation,
      :enable_cancellation_policy,
      :show_page_enabled,
      :availability_templates_attributes => nested(self.availability_template),
      :action_type_ids => []
    ]
  end

  def amenity_type
    [
      :name,
      :amenities_attributes => nested(self.amenity)
    ]
  end

  def location_type
    [
      :name
    ]
  end

  def instance_payment_gateway
    [
      :payment_gateway_id,
      :live_settings,
      :test_settings,
      :country,
      :name,
      :supported_countries
    ]
  end

  def instance_admin_buy_sell_configuration
    [
      :currency,
      :currency_symbol_position,
      :currency_decimal_mark,
      :currency_thousands_separator,
      :shipment_inc_vat,
      :infinite_scroll,
      :random_products_for_cross_sell
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
      :redirect_url
    ]
  end

  def instance_view
    [
      :body,
      :path,
      :format,
      :handler,
      :locale,
      :partial
    ]
  end

  def partner
    [
      :name,
      :search_scope_option,
      :domain_attributes => nested(self.domain),
      :theme_attributes => self.theme
    ]
  end

  def spree_product
    [
      :name,
      :sku,
      :slug,
      :description,
      :price,
      :cost_price,
      :cost_currency,
      :available_on,
      :weight,
      :height,
      :width,
      :depth,
      :shipping_category_id,
      :tax_category_id,
      :meta_keywords,
      :meta_description,
      :shipping_category_attributes => nested(self.spree_shipping_category),
      option_type_ids: [],
      taxon_ids: []
    ]
  end

  def spree_shipping_category
    [
      :name
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
      theme_font_attributes: nested(self.theme_font),
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
      :answer
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
      attachment_ids: [],
    ]
  end

  def user_message
    [
      :body,
      :replying_to_id
    ]
  end

  def inquiry
    [
      :name,
      :company_name,
      :email
    ]
  end

  def rating
    [
      :comment,
      :value
    ]
  end

  def company
    [
      :name,
      :url,
      :email,
      :description,
      :mailing_address,
      :paypal_email,
      :bank_owner_name,
      :bank_routing_number,
      :bank_account_number,
      :white_label_enabled,
      :listings_public,
      locations_attributes: nested(self.location),
      domain_attributes: nested(self.domain),
      approval_requests_attributes: nested(self.approval_request),
      theme_attributes: self.theme,
      industry_ids: [],
      products_attributes: nested(self.spree_product)
    ]
  end

  def domain
    [
      :name,
      :target,
      :target_id,
      :target_type,
      :secured,
      :white_label_enabled,
      :google_analytics_tracking_code,
      :certificate_body,
      :private_key,
      :certificate_chain,
      :redirect_to,
      :redirect_code
    ]
  end

  def location_address
    [
      :address, :address2, :formatted_address, :postcode,
      :suburb, :city, :state, :country, :street, :address_components,
      :latitude, :local_geocoding, :longitude, :state_code
    ]
  end

  def location
    [
      :company_id, :description, :email,
      :info, :currency,
      :phone, :availability_template_id, :special_notes,
      :location_type_id, :photos,
      :administrator_id, :name, :location_address,
      :availability_template_id,
      availability_rules_attributes: nested(self.availability_rule),
      location_address_attributes: nested(self.location_address),
      listings_attributes: nested(self.transactable),
      approval_requests_attributes: nested(self.approval_request),
      amenity_ids: [],
      waiver_agreement_template_ids: []
    ] + self.location_address
  end

  def transactable(transactable_type = nil)
    Transactable::PRICE_TYPES.collect{|t| "#{t}_price".to_sym} +
      [
        :location_id, :availability_template_id,
        :defer_availability_rules, :free,
        :hourly_reservations, :price_type, :draft, :enabled,
        :last_request_photos_sent_at, :activated_at, :rank,
        :transactable_type_id, :transactable_type,
        photos_attributes: nested(self.photo),
        approval_requests_attributes: nested(self.approval_request),
        availability_rules_attributes: nested(self.availability_rule),
        photo_ids: [],
        amenity_ids: [],
        waiver_agreement_template_ids: [],
    ] +
    Transactable.public_custom_attributes_names((transactable_type.presence || PlatformContext.current.try(:instance).try(:transactable_types).try(:first)).try(:id))
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
    ]
  end

  def amenity
    [
      :name,
      :amenity_type_id
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
      approval_request_attachments_attributes: nested(self.approval_request_attachment)
    ]
  end

  def approval_request_template
    [
      :owner_type, :required_written_verification,
      approval_request_attachment_templates_attributes: nested(self.approval_request_attachment_template)
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
      :file_cache,
    ]
  end

  def photo
    [
      :image,
      :caption,
      :image_versions_generated_at,
      :position,
      :transactable_id
    ]
  end

  def user
    [
      :name, :email, :phone, :job_title, :password, :avatar,
      :avatar_versions_generated_at, :avatar_transformation_data,
      :biography, :country_name, :mobile_number,
      :facebook_url, :twitter_url, :linkedin_url, :instagram_url,
      :current_location, :company_name, :skills_and_interests,
      :last_geolocated_location_longitude, :last_geolocated_location_latitude,
      :sms_notifications_enabled, :domain_id, :time_zone,
      :phone_required, :country_name_required, :skip_password,
      :country_name, :phone, :mobile_phone,
      :first_name, :middle_name, :last_name, :gender,
      :drivers_licence_number, :gov_number, :twitter_url,
      :linkedin_url, :facebook_url, :google_plus_url,
      industry_ids: [],
      companies_attributes: nested(self.company),
      approval_requests_attributes: nested(self.approval_request),
      user_instance_profiles_attributes: nested(self.user_instance_profiles)
    ]
  end

  def user_instance_profiles
    UserInstanceProfile.public_custom_attributes_names(InstanceProfileType.first.try(:id))
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
end
