class SecuredParams

  def boarding_form(product_type=nil)
    [
      :draft,
      user_attributes: nested(self.user),
      seller_profile_properties: nested(self.seller),
      company_attributes: nested(self.company),
      product_form: nested(self.product_form(product_type))
    ]
  end

  def shipping_category_form
    [
      :name,
      shipping_methods_attributes: nested(self.spree_shipping_method)
    ]
  end

  def product_form(product_type=nil)
    [
      :draft,
      :name,
      :description,
      :price,
      :quantity,
      :shippo_enabled,
      :insurance_amount,
      :weight,
      :depth,
      :width,
      :height,
      :weight_unit,
      :depth_unit,
      :width_unit,
      :height_unit,
      :shipping_category_id,
      :unit_of_measure,
      :action_rfq,
      image_ids: [],
      attachment_ids: [],
      category_ids: [],
      company_address_attributes: nested(self.address),
      images_attributes: nested(self.spree_image),
      document_requirements_attributes: nested(self.document_requirement),
      upload_obligation_attributes: nested(self.upload_obligation),
      shipping_methods_attributes: nested(self.spree_shipping_method),
      additional_charge_types_attributes: nested(self.additional_charge_type),
      extra_properties:  Spree::Product.public_custom_attributes_names((product_type.presence || PlatformContext.current.try(:instance).try(:product_types).try(:first)).try(:id)),
    ]
  end

  def instance_shipping_providers
    [
      :shippo_api_token
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

  def custom_attribute
    [ :name,
      :attribute_type,
      :html_tag,
      :prompt,
      :required,
      :min_length,
      :max_length,
      :default_value,
      :public,
      :label,
      :placeholder,
      :hint,
      :searchable,
      :input_html_options,
      :wrapper_html_options,
      :input_html_options_string,
      :wrapper_html_options_string,
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
      :validatable_type
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
      :country_ids,
      :state_ids,
      state_ids: [],
      country_ids: []
    ]
  end

  def custom_model_type
    [
      :name,
      service_type_ids: [],
      project_type_ids: [],
      product_type_ids: [],
      offer_type_ids: [],
      reservation_type_ids: [],
      instance_profile_type_ids: []
    ]
  end

  def category
    [
      :name,
      :in_top_nav,
      :top_nav_position,
      :parent_id,
      :child_index,
      :multiple_root_categories,
      :search_options,
      :display_options,
      :mandatory,
      service_type_ids: [],
      project_type_ids: [],
      product_type_ids: [],
      offer_type_ids: [],
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
      owner_attributes: nested([:user_blogs_enabled])
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
      :published_at,
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
      :live_balanced_api_key,
      :live_paypal_app_id,
      :live_paypal_client_id,
      :live_paypal_client_secret,
      :live_paypal_password,
      :live_paypal_signature,
      :live_paypal_username,
      :live_stripe_api_key,
      :live_stripe_public_key,
      :mark_as_locked,
      :marketplace_password,
      :name,
      :olark_api_key,
      :olark_enabled,
      :onboarding_verification_required,
      :password_protected,
      :payment_transfers_frequency,
      :paypal_email,
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
      :test_balanced_api_key,
      :test_mode,
      :test_paypal_app_id,
      :test_paypal_client_id,
      :test_paypal_client_secret,
      :test_paypal_password,
      :test_paypal_signature,
      :test_paypal_username,
      :test_stripe_api_key,
      :test_stripe_public_key,
      :test_twilio_consumer_key,
      :test_twilio_consumer_secret,
      :test_twilio_from_number,
      :time_zone,
      :tt_select_type,
      :twilio_consumer_key,
      :twilio_consumer_secret,
      :twilio_from_number,
      :twitter_consumer_key,
      :twitter_consumer_secret,
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
      allowed_currencies: [],
      allowed_countries: [],
      custom_translations: [:'buy_sell_market.checkout.manual_payment', :'buy_sell_market.checkout.manual_payment_description'],
      domains_attributes: nested(self.domain),
      listing_amenity_types_attributes: nested(self.amenity_type),
      location_types_attributes: nested(self.location_type),
      location_amenity_types_attributes: nested(self.amenity_type),
      text_filters_attributes: nested(self.text_filter),
      transactable_types_attributes: nested(self.transactable_type),
      translations_attributes: nested(self.translation),
      theme_attributes: self.theme
    ]
  end

  def instance_profile_type
    [
      :searchable,
      :show_categories,
      :category_search_type,
      :position,
      custom_attributes_attributes: [:searchable, :id]
    ]
  end

  def spree_image
    [
      :position
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

  def spree_order
    [
      :card_number,
      :card_code,
      :card_exp_month,
      :card_exp_year,
      :card_holder_first_name,
      :card_holder_last_name,
      :express_token,
      :payment_method_id,
      :start_express_checkout,
      :insurance_enabled,
      additional_charges_attributes: nested(self.additional_charge),
      payment_documents_attributes: nested(self.payment_document),
      payment_attributes: nested(self.payment),
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
      payment_document_info_attributes: nested(self.payment_document_info)
    ]
  end

  def payment_document_info
    [
      :document_requirement_id,
      :attachment_id
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

  def spree_shipping_method
    [
      :name,
      :hidden,
      :removed,
      :admin_name,
      :display_on,
      :deleted_at,
      :tracking_url,
      :tax_category_id,
      :processing_time,
      calculator_attributes: nested(self.calculator),
      zones_attributes: nested(self.zone),
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
      :propagate_all_variants,
      stock_items_attributes: nested(self.spree_stock_item)
    ]
  end

  def spree_stock_item
    [
      :variant,
      :backorderable,
      stock_movements_attributes: nested(self.spree_stock_movement)

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

  def product_type
    [
      :name,
      :action_rfq,
      :searchable
    ]
  end

  def transactable_type
    [
      :action_book_it_out,
      :action_exclusive_price,
      :action_price_per_unit,
      :action_weekly_subscription_booking,
      :action_monthly_subscription_booking,
      :action_rfq,
      :action_overnight_booking,
      :action_regular_booking,
      :action_booking,
      :action_recurring_booking,
      :action_free_booking,
      :action_hourly_booking,
      :action_daily_booking,
      :action_weekly_booking,
      :action_monthly_booking,
      :availability_options,
      :action_continuous_dates_booking,
      :action_na,
      :allow_save_search,
      :bookable_noun, :lessor, :lessee, :action_schedule_booking,
      :bookable_noun, :lessor, :lessee,
      :cancellation_policy_enabled,
      :cancellation_policy_penalty_percentage,
      :cancellation_policy_hours_for_cancellation,
      :category_search_type,
      :default_search_view,
      :date_pickers_use_availability_rules,
      :date_pickers_mode,
      :default_currency,
      :default_availability_template_id,
      :enable_cancellation_policy,
      :enable_photo_required,
      :favourable_pricing_rate,
      :hours_to_expiration,
      :name,
      :minimum_booking_minutes,
      :show_page_enabled,
      :groupable_with_others,
      :service_fee_guest_percent, :service_fee_host_percent,
      :min_daily_price,
      :max_daily_price,
      :min_hourly_price,
      :max_hourly_price,
      :min_weekly_price,
      :max_weekly_price,
      :min_monthly_price,
      :max_monthly_price,
      :skip_location,
      :rental_shipping,
      :show_company_name,
      :searchable,
      :search_engine,
      :searcher_type,
      :search_radius,
      :search_placeholder,
      :show_categories,
      :timezone_rule,
      :show_price_slider,
      :search_price_types_filter,
      :show_date_pickers,
      :date_pickers_use_availability_rules,
      :date_pickers_mode,
      :default_availability_template_id,
      :show_path_format,
      :availability_templates_attributes => nested(self.availability_template),
      :allowed_currencies => [],
      :action_type_ids => [],
      schedule_attributes: nested(self.schedule),
      custom_attributes_attributes: [:searchable, :id],
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
      payment_methods_attributes: nested(self.payment_method)
    ]
  end

  def payment_method
    [
      :active,
      :payment_method_type,
      :id
    ]
  end

  def instance_admin_buy_sell_configuration
    [
      :currency,
      :currency_symbol_position,
      :currency_decimal_mark,
      :currency_thousands_separator,
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
      :no_layout,
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
      :featured,
      :user_id,
      :weight,
      :height,
      :width,
      :depth,
      :shipping_category_id,
      :tax_category_id,
      :meta_keywords,
      :meta_description,
      :shipping_category_attributes => nested(self.spree_shipping_category),
      option_type_ids: []
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
      :instagram_url,
      :youtube_url,
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

  def comment
    [
      :body,
      :title,
      :creator_id,
      :report_as_spam
    ]
  end

  def company(transactable_type: nil, offer_type: nil)
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
      locations_attributes: nested(self.location(transactable_type)),
      domain_attributes: nested(self.domain),
      approval_requests_attributes: nested(self.approval_request),
      company_address_attributes: nested(self.address),
      payments_mailing_address_attributes: nested(self.address),
      theme_attributes: self.theme,
      industry_ids: []
    ] << {
      products_attributes: nested(self.spree_product),
      offers_attributes: nested(self.offer(offer_type)),
      shipping_categories_attributes: nested(self.spree_shipping_category),
      shipping_methods_attributes: nested(self.spree_shipping_method),
      stock_locations_attributes: nested(self.spree_stock_location),
    }.merge(MerchantAccount::MERCHANT_ACCOUNTS.inject({}) do |hsh, (name, klass)|
      attributes = nested(klass::ATTRIBUTES)
      attributes << {payment_subscription_attributes: nested(self.payment_subscription) }
      owner_klass = "MerchantAccountOwner::#{name.classify}MerchantAccountOwner".safe_constantize
      attributes << {owners_attributes: nested([:document] + owner_klass::ATTRIBUTES)} if owner_klass
      attributes << {current_address_attributes: nested([:address]) }
      hsh[:"#{name}_merchant_account_attributes"] = attributes
      hsh
    end)
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
      :remove_uploaded_robots_txt
    ]
  end

  def address
    [
      :address, :address2, :formatted_address, :postcode,
      :suburb, :city, :state, :country, :street, :should_check_address,
      :latitude, :local_geocoding, :longitude, :state_code, :raw_address,
      address_components: [:long_name , :short_name, :types]
    ]
  end

  def form_component
    [ :form_type, :name ]
  end

  def location(transactable_type = nil)
    [
      :description, :email, :info, :currency,
      :phone, :availability_template_id, :special_notes,
      :location_type_id, :photos,
      :administrator_id, :name, :location_address,
      :availability_template_id,
      :time_zone,
      availability_template_attributes: nested(self.availability_template),
      location_address_attributes: nested(self.address),
      listings_attributes: nested(self.transactable(transactable_type)),
      approval_requests_attributes: nested(self.approval_request),
      amenity_ids: [],
      waiver_agreement_template_ids: []
    ] + self.address
  end

  def transactable(transactable_type)
    [
      :name, :description, :capacity, :confirm_reservations,
      :location_id, :availability_template_id, :free,
      :price_type, :draft, :enabled,
      :hourly_price, :daily_price, :weekly_price, :monthly_price, :fixed_price, :fixed_price_cents,
      :enable_daily, :enable_weekly, :enable_monthly,
      :hourly_price_cents, :daily_price_cents, :weekly_price_cents, :monthly_price_cents,
      :weekly_subscription_price_cents, :monthly_subscription_price_cents,
      :enable_weekly_subscription, :enable_monthly_subscription,
      :weekly_subscription_price, :monthly_subscription_price,
      :deposit_amount,
      :book_it_out_discount,
      :book_it_out_minimum_qty,
      :enable_exclusive_price,
      :enable_deposit_amount,
      :enable_book_it_out_discount,
      :exclusive_price,
      :featured,
      :action_rfq,
      :quantity, :currency,
      :action_recurring_booking,
      :action_hourly_booking,
      :action_free_booking,
      :action_daily_booking,
      :action_subscription_booking,
      :last_request_photos_sent_at, :activated_at, :rank,
      :transactable_type_id, :transactable_type, :booking_type,
      :insurance_value,
      :rental_shipping_type, :dimensions_template_id,
      :minimum_booking_minutes,
      photos_attributes: nested(self.photo),
      approval_requests_attributes: nested(self.approval_request),
      photo_ids: [],
      amenity_ids: [],
      category_ids: [],
      dimensions_template_attributes: nested(self.dimensions_template),
      attachment_ids: [],
      waiver_agreement_template_ids: [],
      schedule_attributes: nested(self.schedule),
      document_requirements_attributes: nested(self.document_requirement),
      upload_obligation_attributes: nested(self.upload_obligation),
      availability_template_attributes: nested(self.availability_template),
      additional_charge_types_attributes: nested(self.additional_charge_type),
      customizations_attributes: nested(self.customization(transactable_type))
    ] +
    Transactable.public_custom_attributes_names((transactable_type || PlatformContext.current.try(:instance).try(:service_types).try(:first)).try(:id))
  end

  def customization(transactable_type)
    [
      :custom_model_type_id,
      properties: transactable_type ? transactable_type.custom_model_types.map{|cmt| Customization.public_custom_attributes_names(cmt)}.flatten : []
    ]
  end

  def project(transactable_type, is_project_owner = false)
    based_params = ([
      :description,
      :transactable_type_id,
      :seek_collaborators,
      photos_attributes: nested(self.photo),
      links_attributes: nested(self.link),
      photo_ids: [],
      topic_ids: [],
    ] + Project.public_custom_attributes_names((transactable_type || PlatformContext.current.try(:instance).try(:project_types).try(:first)).try(:id)))
    based_params += [ :name, :summary, new_collaborators: [ :email, :id, :_destroy ], new_collaborators_attributes: nested(self.project_collaborator) ] if is_project_owner
    based_params
  end

  def offer(offer_type)
    [
      :name,
      :description,
      :summary,
      :price,
      :price_cents,
      :creator_id,
      :transactable_type_id,
      photos_attributes: nested(self.photo),
      photo_ids: [],
      category_ids: [],
      attachment_ids: [],
      document_requirements_attributes: nested(self.document_requirement),
      upload_obligation_attributes: nested(self.upload_obligation),
      approval_requests_attributes: nested(self.approval_request)
    ] + Offer.public_custom_attributes_names((offer_type || PlatformContext.current.try(:instance).try(:offer_types).try(:first)).try(:id))
  end

  def reservation
    [
      :comment,
      periods_attributes: nested(self.period),
      additional_charges_attributes: nested(self.additional_charge)
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
      transactable_type_ids: []
    ]
  end

  def bid(reservation_type)
    [
      properties: Bid.public_custom_attributes_names(reservation_type),
      payment_documents_attributes: nested(self.payment_document)
    ]
  end

  def project_collaborator
    [
      :approved,
      :email
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
      schedule_rules_attributes: nested(self.schedule_rule),
      schedule_exception_rules_attributes: nested(self.schedule_exception_rule)
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
      user_dates: [],
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
      :draft_at,
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
      :id,
      :image,
      :caption,
      :position
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

  def user(transactable_type: nil, reservation_type: nil, offer_type: nil)
    [
      :avatar,
      :avatar_transformation_data,
      :avatar_versions_generated_at,
      :biography,
      :company_name,
      :country_name,
      :drivers_licence_number,
      :email,
      :facebook_url,
      :first_name,
      :gender,
      :google_plus_url,
      :gov_number,
      :instagram_url,
      :job_title,
      :language,
      :last_name,
      :linkedin_url,
      :middle_name,
      :mobile_number,
      :mobile_phone,
      :name,
      :password,
      :phone,
      :public_profile,
      :skills_and_interests,
      :skip_password,
      :sms_notifications_enabled,
      :time_zone,
      :twitter_url,
      industry_ids: [],
      category_ids: [],
      seller_profile_attributes: nested(self.seller_profile),
      buyer_profile_attributes: nested(self.buyer_profile),
      default_profile_attributes: nested(self.default_profile),
      current_address_attributes: nested(self.address),
      companies_attributes: nested(self.company(transactable_type: transactable_type)),
      approval_requests_attributes: nested(self.approval_request),
      projects_attributes: nested(self.project(transactable_type)),
    ]
  end

  def user_from_instance_admin
    self.user + [
      :featured,
      default_profile_attributes: nested(self.default_profile_with_private_attribs)
    ]
  end

  def default_profile
    [
      properties: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id)),
      category_ids: [],
      customizations_attributes: nested(self.customization(PlatformContext.current.instance.default_profile_type))
    ]
  end

  def seller_profile
    [
      properties: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.seller_profile_type.try(:id)),
      category_ids: [],
      customizations_attributes: nested(self.customization(PlatformContext.current.instance.seller_profile_type))
    ]
  end

  def buyer_profile
    [
      properties: UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id)),
      category_ids: [],
      customizations_attributes: nested(self.customization(PlatformContext.current.instance.buyer_profile_type))
    ]
  end

  def default_profile_with_private_attribs
    [
      properties: PlatformContext.current.instance.default_profile_type.custom_attributes.pluck(&:name),
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
      :click_to_call
    ]
  end

  def user_instance_profiles

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
      data_source_attributes: nested(self.data_source)
    ]
  end

  def workflow_step()
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
      :replt_to_type,
      :use_ssl,
      :request_type,
      :endpoint,
      :headers,
      :payload_data,
      :cc,
      :bcc,
      :subject,
      :layout_path
    ] + (step_associated_class.present? && defined?(step_associated_class.constantize::CUSTOM_OPTIONS) ? [custom_options: step_associated_class.constantize::CUSTOM_OPTIONS] : [])
  end

  def data_source
    [
      :type,
      settings: [:endpoint],
      fields: [],
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
      rating_systems_attributes: self.rating_system
    ]
  end

  def rating_system
    [
      :id,
      :subject,
      :active,
      :transactable_type_id,
      rating_hints_attributes: self.nested(self.rating_hint),
      rating_questions_attributes: self.nested(rating_question)
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
      :text,
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
      properties: Reservation.public_custom_attributes_names(reservation_type),
      dates: [],
      category_ids: [],
      additional_charge_ids: [],
      waiver_agreement_templates: [],
      shipments_attributes: nested(self.shipment),
      payment_attributes: nested(self.payment),
      documents: nested(self.payment_document),
      documents_attributes: nested(self.payment_document),
      shipments_attributes: nested(self.shipment),
      payment_documents_attributes: nested(self.payment_document),
      owner_attributes: nested(self.user),
      address_attributes: nested(self.address)
    ]
  end

  def payment
    [
      :payment_method_id,
      :payment_method_nonce,
      :chosen_credit_card_id,
      credit_card_attributes: nested(self.credit_card)
    ]
  end

  def payment_subscription
    [
      :payment_method_id,
      :credit_card_id,
      :chosen_credit_card_id,
      credit_card_attributes: nested(self.credit_card)
    ]
  end

  def credit_card
    [
      :number,
      :verification_value,
      :month,
      :year,
      :first_name,
      :last_name
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
      rating_answers: self.rating_answer
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
      :provider_commission_percentage,
      :status,
      :selected,
      :instance_id,
      :additional_charge_type_target,
      :additional_charge_type_id,
      :_destroy
    ]
  end

  def additional_charge_type
    [
      :id,
      :name,
      :description,
      :amount,
      :percent,
      :currency,
      :commission_receiver,
      :provider_commission_percentage,
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
    [ :level ]
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
      shipping_address_attributes: self.shipping_address
    ]
  end

  def shipping_address
    [
      :user_id,
      :shippo_id,
      :name,
      :company,
      :street1,
      :street2,
      :city,
      :zip,
      :state,
      :phone,
      :email,
      :country
    ]
  end

  def user_status_update
    [
      :text,
      :user_id,
      :instance_id,
      :topic_ids,
      :updateable_id,
      :updateable_type
    ]
  end

  def seller_attachment(instance)
    allowed = [:title]
    allowed << :access_level if instance.seller_attachments_access_sellers_preference?
    allowed
  end
end
