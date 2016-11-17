namespace :just_hala do
  desc 'Setup Just Hala'
  task setup: :environment do
    @instance = Instance.find(175)
    @instance.set_context!
    @instance.update_attributes(
      wish_lists_enabled: true,
      enable_reply_button_on_host_reservations: true,
      force_accepting_tos: true,
      bookable_noun: 'Ninja',
      default_country: 'United States',
      default_currency: 'USD',
      skip_company: true,
      split_registration: true,
      hidden_ui_controls: {
        'dashboard/companies' => '1',
        'dashboard/users' => '1',
        'dashboard/waiver_agreement_templates' => '1',
        'dashboard/white_labels' => '1',
        'dashboard/transactables/bulk_upload' => '1',
        'main_menu/view_profile' => '1'
      }
    )

    if @service_type = @instance.transactable_types.first
      @service_type.update!(name: 'Ninja',
                            slug: 'ninja',
                            action_free_booking: false,
                            action_daily_booking: false,
                            action_weekly_booking: false,
                            action_monthly_booking: false,
                            action_regular_booking: true,
                            show_path_format: '/:transactable_type_id/:id',
                            cancellation_policy_enabled: '1',
                            cancellation_policy_hours_for_cancellation: 24,
                            cancellation_policy_penalty_hours: 1.5,
                            default_search_view: 'list',
                            skip_payment_authorization: true,
                            hours_for_guest_to_confirm_payment: 24,
                            single_transactable: true,
                            show_price_slider: true,
                            service_fee_guest_percent: 0,
                            service_fee_host_percent: 30,
                            skip_location: true,
                            show_categories: true,
                            category_search_type: 'AND',
                            bookable_noun: 'Ninja',
                            enable_photo_required: true,
                            min_hourly_price_cents: 50_00,
                            max_hourly_price_cents: 150_00,
                            lessor: 'Ninja',
                            lessee: 'Client',
                            enable_reviews: true)
      @service_type.update_column(:cancellation_policy_enabled, Time.zone.now)
    else
      @service_type = @instance.transactable_types.create(
        name: 'Ninja',
        slug: 'ninja',
        min_hourly_price_cents: 50_00,
        max_hourly_price_cents: 150_00,
        action_free_booking: false,
        enable_photo_required: true,
        show_path_format: '/:transactable_type_id/:id',
        cancellation_policy_enabled: '1',
        service_fee_guest_percent: 0,
        service_fee_host_percent: 30,
        cancellation_policy_hours_for_cancellation: 24,
        cancellation_policy_penalty_hours: 1.5,
        action_hourly_booking: '1',
        action_daily_booking: false,
        action_weekly_booking: false,
        action_monthly_booking: false,
        availability_options: { 'defer_availability_rules' => true, 'confirm_reservations' => { 'default_value' => true, 'public' => true } },
        default_search_view: 'list',
        skip_payment_authorization: true,
        skip_location: true,
        hours_for_guest_to_confirm_payment: 24,
        category_search_type: 'AND',
        show_price_slider: true,
        single_transactable: true,
        show_categories: true,
        bookable_noun: 'Ninja',
        lessor: 'Ninja',
        lessee: 'Client',
        enable_reviews: true
      )
    end
    @reservation_type = ReservationType.first || ReservationType.create!(name: 'Mission', transactable_types: TransactableType.all)
    @reservation_type.update!(settings: {
                                precise_search: true,
                                address_in_radius: true
                              })
    reservation_components = @reservation_type.form_components.first || (Utils::FormComponentsCreator.new(@reservation_type).create! && @reservation_type.form_components.first)
    root_category = Category.where(name: 'Services').first_or_create!
    root_category.transactable_types = TransactableType.all
    root_category.mandatory = true
    root_category.multiple_root_categories = true
    root_category.search_options = 'include'
    root_category.save!
    %w(Mac PC Mobile Training).each do |category|
      root_category.children.where(name: category).first_or_create!
    end
    create_custom_attributes
    reservation_components.form_fields = [
      { 'reservation' => 'service_category' },
      { 'reservation' => 'dates' },
      { 'reservation' => 'address' },
      { 'reservation' => 'technical_description' }
    ]

    update_rating_system
    reservation_components.save!
    update_form_components
    create_views
    create_testimonials
    create_content_holders
    set_theme_options
    upload_logo_images
    create_translations
    create_workflow_alerts
    create_custom_validators!
    expire_cache
  end

  def expire_cache
    CacheExpiration.send_expire_command 'InstanceView', instance_id: 175
    CacheExpiration.send_expire_command 'Translation', instance_id: 175
    CacheExpiration.send_expire_command 'CustomAttribute', instance_id: 175
    Rails.cache.clear
  end

  def update_rating_system
    @service_type.rating_systems.each do |rs|
      rs.rating_hints.each { |rh| rh.description = "Test#{rh.value}" }
      rs.rating_questions.first_or_initialize(text: 'Are you satisfied ?')
      rs.active = true
      rs.save
    end
  end

  def update_form_components
    @service_type.form_components.where(name: 'Pricing & Availability').destroy_all

    @service_type.form_components.where(
      name: 'Tell us a little about your company'
    ).destroy_all

    @service_type.form_components.where(
      name: 'And finally, your contact information?'
    ).destroy_all

    component = @service_type.form_components.find_by(name: [
      'Where is your Expert located?',
      'What is your location?'
    ])
    if component
      component.name = 'What is your location?'
      component.form_fields = [
        { 'location' => 'name' },
        { 'location' => 'address' },
        { 'user' => 'phone' },
        { 'transactable' => 'service_radius' }
      ]
      component.save!
    end

    component = @service_type.form_components.find_by(name: [
      "Please tell us about the Expert you're listing",
      'Please complete the following Ninja Profile Questions'
    ])
    component.form_fields = [
      { 'transactable' => 'name' },
      { 'transactable' => 'description' },
      { 'transactable' => 'price' },
      { 'transactable' => 'photos' },
      { 'transactable' => 'Category - Services' },
      { 'transactable' => 'education' },
      { 'transactable' => 'technical_certifications' },
      { 'transactable' => 'languages' },
      { 'transactable' => 'service_area' },
      { 'transactable' => 'conditions' },
      { 'transactable' => 'video_url' },
      { 'transactable' => 'availability_rules' },
      { 'transactable' => 'Custom Model - Testimonials' }
    ]
    component.name = 'Please complete the following Ninja Profile Questions'
    component.save!

    component = FormComponent.find_by(form_type: 'buyer_registration')
    component.form_fields = [
      { 'user' => 'name' },
      { 'user' => 'email' },
      { 'user' => 'password' },
      { 'user' => 'phone' }
    ]
    component.save!

    component = FormComponent.find_by(form_type: 'seller_registration')
    component.form_fields = [
      { 'user' => 'name' },
      { 'user' => 'email' },
      { 'user' => 'password' },
      { 'user' => 'phone' }
    ]
    component.save!

    component = FormComponent.find_by(name: 'Profile')
    component.form_fields = [
      { 'user' => 'name' },
      { 'user' => 'email' },
      { 'user' => 'password' },
      { 'user' => 'phone' },
      { 'user' => 'avatar' },
      { 'user' => 'facebook_url' },
      { 'user' => 'twitter_url' },
      { 'user' => 'linkedin_url' },
      { 'user' => 'instagram_url' },
      { 'user' => 'google_plus_url' },
      { 'user' => 'current_address' },
      { 'user' => 'approval_requests' }
    ]
    component.save!

    component = FormComponent.find_by(name: ['Details', 'Ninja Profile'])
    component.form_fields = [
      { 'transactable' => 'enabled' },
      { 'transactable' => 'approval_requests' },
      { 'transactable' => 'waiver_agreement_templates' },
      { 'transactable' => 'documents_upload' },
      { 'transactable' => 'name' },
      { 'transactable' => 'description' },
      { 'transactable' => 'location_id' },
      { 'transactable' => 'service_radius' },
      { 'transactable' => 'schedule' },
      { 'transactable' => 'price' },
      { 'transactable' => 'photos' },
      { 'transactable' => 'Category - Services' },
      { 'transactable' => 'education' },
      { 'transactable' => 'technical_certifications' },
      { 'transactable' => 'languages' },
      { 'transactable' => 'service_area' },
      { 'transactable' => 'conditions' },
      { 'transactable' => 'video_url' },
      { 'transactable' => 'Custom Model - Testimonials' }
    ]
    component.name = 'Ninja Profile'
    component.save!
  end

  def create_testimonials
    custom_model = @service_type.custom_model_types.where(
      name: 'Testimonials'
    ).first_or_create!
    custom_model.custom_attributes.where(
      name: 'testimonial_body',
      label: 'Body',
      attribute_type: 'string',
      html_tag: 'textarea',
      public: true
    ).first_or_create!
    custom_model.custom_attributes.where(
      name: 'testimonial_author',
      label: 'Author',
      attribute_type: 'string',
      html_tag: 'input',
      public: true
    ).first_or_create!
  end

  def create_custom_attributes
    @service_type.custom_attributes.where(name: 'service_radius',
                                          label: 'Service radius',
                                          attribute_type: 'integer',
                                          html_tag: 'input',
                                          default_value: 5,
                                          public: true).first_or_create!
    @service_type.custom_attributes.where(name: 'education',
                                          label: 'Education',
                                          attribute_type: 'string',
                                          html_tag: 'textarea',
                                          public: true).first_or_create!
    @service_type.custom_attributes.where(name: 'technical_certifications',
                                          label: 'Technical Certifications',
                                          attribute_type: 'string',
                                          html_tag: 'textarea',
                                          public: true).first_or_create!
    languages = @service_type.custom_attributes.where(name: 'languages',
                                                      label: 'Languages',
                                                      attribute_type: 'array',
                                                      html_tag: 'check_box_list',
                                                      public: true).first_or_create!
    languages.valid_values = %w(English Spanish Chinese Tagalog Vietnamese Korean Farsi Russian Arabic French Italian Polish)
    languages.save!
    @service_type.custom_attributes.where(name: 'service_area',
                                          label: 'Service Area',
                                          attribute_type: 'string',
                                          html_tag: 'textarea',
                                          public: true).first_or_create!
    @service_type.custom_attributes.where(name: 'conditions',
                                          label: 'Conditions',
                                          attribute_type: 'string',
                                          html_tag: 'textarea',
                                          public: true).first_or_create!
    @service_type.custom_attributes.where(name: 'video_url',
                                          label: 'Video URL',
                                          attribute_type: 'string',
                                          html_tag: 'input',
                                          public: true).first_or_create!
    mobile = @reservation_type.custom_attributes.where(name: 'mobile_number').first
    mobile.destroy! if mobile
    service_category = @reservation_type.custom_attributes.where(name: 'service_category',
                                                                 label: 'Confirm the services you are interested in',
                                                                 attribute_type: 'array',
                                                                 html_tag: 'check_box_list',
                                                                 public: true).first_or_initialize
    service_category.valid_values =  %w(Mac PC Mobile Training)
    service_category.required = 1
    service_category.set_validation_rules!
    @reservation_type.custom_attributes.where(name: 'technical_description',
                                              label: 'Technical Support Description',
                                              attribute_type: 'string',
                                              html_tag: 'textarea',
                                              public: true).first_or_create!
  end

  def create_views
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'listings/reservations/summary'
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %{
<div></div>
{% content_for domready %}
  $('input[type="checkbox"][disabled]').parent('label').tooltip({title: 'This Ninja does not provide such service. Please find another Ninja.', placement: 'top'});
{% endcontent_for %}
      },
               format: 'html',
               handler: 'liquid',
               partial: true,
               locales: Locale.all,
               view_type: 'view')
    iv.save!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/host_reservations/complete_reservation_top'
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: "
<h2>{{ 'dashboard.host_reservations.complete_reservation.client' | translate}}</h2>
<p><a href='{{ reservation.owner.user_profile_url }}'>{{ @reservation.owner.name }}</a></p>

<h2>{{ 'dashboard.host_reservations.complete_reservation.services' | translate }}</h2>
<p>{{ @reservation['properties']['service_category'] | split: ',' | compact | join: ', ' }}</p>

<h2>{{ 'dashboard.host_reservations.complete_reservation.date_and_time' | translate }}</h2>
<p>{{ @reservation.starts_at | localize }}</p>

{% if reservation.rejection_reason != blank %}
  <h2>{{ 'dashboard.host_reservations.complete_reservation.rejection_reason' | translate }}</h2>
  <p>{{ reservation.rejection_reason }}</p>
{% endif %}
<hr>",
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
    iv = InstanceView.where(
      instance_id: @instance.id,
      partial: true,
      path: 'search/list/search_filters_boxes'
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %{
<div class='search-filter-box-wrapper'>
  <div class="search-filter-box" data-filter data-search-filters-container>
    <h3>
      Hourly rate
    </h3>
    <ul>
      <li>
        <label class="radio small-radio checked">
          <span class="radio-icon-outer"><span class="radio-icon-inner"></span></span>
          <input {% if params['price']['max'] == '' %}checked{% endif %} data-list-view="1" name="price[max]" type="radio" value="">
          <span class="filter-label-text">
            Any rate
          </span>
        </label>
      </li>
      <li>
        <label class="radio small-radio checked">
          <span class="radio-icon-outer"><span class="radio-icon-inner"></span></span>
          <input {% if params['price']['max'] == '60' %}checked{% endif %} data-list-view="1" name="price[max]" type="radio" value="60">
          <span class="filter-label-text">
            Below $60/hr
          </span>
        </label>
      </li>
      <li>
        <label class="radio small-radio checked">
          <span class="radio-icon-outer"><span class="radio-icon-inner"></span></span>
          <input {% if params['price']['max'] == '90' %}checked{% endif %} data-list-view="1" name="price[max]" type="radio" value="90">
          <span class="filter-label-text">
            Below $90/hr
          </span>
        </label>
      </li>
    </ul>
  </div>
</div>

<div class='search-filter-box-wrapper'>
  <div class="search-filter-box" data-filter data-search-filters-container>
    <h3>
      Date
    </h3>
    <input name="date_fake" type="text" data-jquery-datepicker value="{{ params['date'] | localize: 'day_month_year' }}" placeholder="Select date">
  </div>
</div>

<div class='search-filter-box-wrapper'>
  <div class="search-filter-box" data-filter data-search-filters-container>
    <h3>
      Time
    </h3>
    <select class="select optional hasCustomSelect time-select" name="time_from">
      <option value="">From</option>
      <option {% if params['time_from'] == '0:00' %} selected {% endif %} value="0:00">12:00 AM</option>
      {% for i in (1..11) %}
      {% assign hour = i | append: ':00' %}
        <option {% if params['time_from'] == hour %} selected {% endif %} value="{{ hour }}">{{ hour }} AM</option>
      {% endfor %}
      <option {% if params['time_from'] == '12:00' %} selected {% endif %} value="12:00">12:00 PM</option>
      {% for i in (13..23) %}
      {% assign hour = i | append: ':00' %}
        <option {% if params['time_from'] == hour %} selected {% endif %} value="{{ hour }}">{{ i | minus: 12 }}:00 PM</option>
      {% endfor %}
    </select>
    <select class="select optional hasCustomSelect time-select" name="time_to">
      <option value="">To</option>
      <option {% if params['time_to'] == '0:00' %} selected {% endif %} value="0:00">12:00 AM</option>
      {% for i in (1..11) %}
      {% assign hour = i | append: ':00' %}
        <option {% if params['time_to'] == hour %} selected {% endif %} value="{{ hour }}">{{ hour }} AM</option>
      {% endfor %}
      <option {% if params['time_to'] == '12:00' %} selected {% endif %} value="12:00">12:00 PM</option>
      {% for i in (13..23) %}
      {% assign hour = i | append: ':00' %}
        <option {% if params['time_to'] == hour %} selected {% endif %} value="{{ hour }}">{{ i | minus: 12 }}:00 PM</option>
      {% endfor %}
    </select>
  </div>
</div>

<div class='search-filter-box-wrapper sort-box'>
  <div class="search-filter-box" data-filter data-search-filters-container>
    <select class="select optional hasCustomSelect" name="sort">
      <option>Sort by</option>
      <option {% if params['sort'] == 'seller_average_rating_desc' %} selected {% endif %}value="seller_average_rating_desc">Highest rating</option>
      <option {% if params['sort'] == 'completed_reservations_desc' %} selected {% endif %}value="completed_reservations_desc">Number of missions</option>
      <option {% if params['sort'] == 'hourly_price_cents_asc' %} selected {% endif %}value="hourly_price_cents_asc">Hourly rate ascending</option>
      <option {% if params['sort'] == 'hourly_price_cents_desc' %} selected {% endif %}value="hourly_price_cents_desc">Hourly rate descending</option>
    </select>
  </div>
</div>
},
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
    iv = InstanceView.where(
      instance_id: @instance.id,
      partial: true,
      path: 'listings/show'
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %{
<div class="container-fluid">
  <article id="space">
    <div class="container-row">
      <div class="two-thirds column left">

        <header class='clearfix'>
          <div class='photo'>
            <img src="{{ listing.photo_url }}" title="{{ listing.name }}" alt="{{ listing.name }}"></img>
          </div>

          <div class='data'>
            <h1 class='username'>Hi, I'm {{ listing.name | filter_text | custom_sanitize }}</h1>
            <div class="price">
              {% assign price_info = listing | lowest_price_without_cents_with_currency %}
              {% if price_info.price %}
                <span>{{ price_info.price}} <span class='period'>/hr</span></span>
              {% elsif price_info.free %}
                <span>{{ 'search.free_listing' | translate }}</span>
              {% endif %}
            </div>
            <div class='address'>
              <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2279/location_marker.png' />
              {{ listing.location.address }}
            <div>
          </div>
        </header>

        {% if listing.description != blank %}
          <div class="about-me">
            <h2>About Me</h2>
            {{ listing.description }}
          </div>
        {% endif %}

        {% if listing.properties.service_area != blank %}
          <div class="service-area">
            <h2>Service Area</h2>
            {{ listing.properties.service_area }}
          </div>
        {% endif %}

        {% if listing.properties.conditions != blank %}
          <div class="conditions">
            <h2>Conditions</h2>
            {{ listing.properties.conditions }}
          </div>
        {% endif %}

        {% if listing.properties.video_url != blank %}
          <div class="video-url">
            {{ listing.properties.video_url | videoify }}
          </div>
        {% endif %}

        {% if listing.customizations.size > 0 %}
          <div class="testimonials">
            <h2>Recommendations</h2>

            <div class='carousel slide' id='testimonials'>
              <div class='carousel-inner'>
                {% for testimonial in listing.customizations %}
                  <div class="item {% if forloop.first %}active{%endif%}">
                    <div class="testimonial-body">{{ testimonial.properties.testimonial_body }}</div>
                    <div class="testimonial-author">{{ testimonial.properties.testimonial_author }}</div>
                  </div>
                {% endfor %}
              </div>

              <ol class="carousel-indicators">
                {% for testimonial in listing.customizations %}
                <li data-target="#testimonials" data-slide-to="{{ forloop.index0 }}" class="{% if forloop.first %}active{%endif%}"></li>
                {% endfor %}
              </ol>
            </div>
          </div>
        {% endif %}

        <div data-reviews-controller="true" data-path="{{ 'reviews_path' | generate_url }}" data-reviewables="[{&quot;id&quot;:{{listing.id}},&quot;type&quot;:&quot;Transactable&quot;,&quot;subject&quot;:&quot;transactable&quot;},{&quot;id&quot;:{{listing.creator.id | default: "-1"}},&quot;type&quot;:&quot;User&quot;,&quot;subject&quot;:&quot;host&quot;}]" {%if platform_context.seller_attachments_enabled? %}data-seller-attachment-path="{{ 'seller_attachments_path' | generate_url }}" data-seller-attachable="{&quot;id&quot;:{{listing.id}},&quot;type&quot;:&quot;Transactable&quot;}"{%endif%}>

          <h2>Ratings</h2>
          <div class="reviews" data-tab-content="true">
          </div>
        </div>

      </div>
      <div class="one-third column left">
        <div class='back-to-search-results'>
          <a data-back-to-search-results-link href="/search">< Back to search results</a>
        </div>

        <div class="hire-me">
          <form id="reservation_request_form_{{ listing.id }}" novalidate="novalidate" class="reservation_request" action="{{ 'review_listing_reservations_path' | generate_url: listing }}" accept-charset="UTF-8" method="post">
            <input name="utf8" type="hidden" value="">
            <input name="authenticity_token" value="{{ form_authenticity_token }}" data-authenticity-token type="hidden">
            <input type="hidden" name="reservation_request[booking_type]" id="reservation_request_booking_type" value="hourly">
            <input type="submit" value="Hire Me!">
          </form>
        </div>

        {% include 'shared/components/wish_list_button_injection.html', object: listing %}

        <div class="missions-count">
          <span>Missions:</span> {{ listing.creator.completed_host_reservations_count }}
        </div>

        <div class="review-stars">
          <span class='details-label'>Rating:</span>
          <span class='star-container'>
            {% for i in (1..listing.creator.seller_average_rating) %}
              <img src="https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2277/star_on.png" />
            {% endfor %}
            {% for i in (listing.creator.seller_average_rating..4) %}
              <img src="https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2278/star_off.png" />
            {% endfor %}
          </span>
        </div>

        <div class="need-help">
          <h2>Need help?</h2>
          <p>Please call: {{ platform_context.phone_number }}</p>
        </div>

        <div class="categories">
          <h2>Services offered:</h2>

          {% for category in listing.transactable_type.categories["Services"]["children"] %}
            {% assign is_included = listing.categories["Services"]["children"] | is_included_in_array: category %}
            {% if is_included %}
              {% assign div_class = "included" %}
            {% else %}
              {% assign div_class = "" %}
            {% endif %}
            <div class="category {{div_class}}">
              <span>{{ category }}</span>
            </div>
          {% endfor %}
        </div>

        <div class ="availability">
          <h2>Days available:</h2>

          <div class="availability-week-container">
            {% for day in listing.available_days %}
              <span class="day-of-week {% if day[1] %}enabled{% else %}disabled{% endif %}">{{ day[0] }}</span>
            {% endfor %}
          </div>

          <div class="availability-detailed-container">
            {% for day in listing.availability_by_days %}
              <div class='week-day'>
                <span class="abbreviation">
                  {{ day[0] }}:
                </span>
                <span class="times-in-day">
                  {% for time in day[1] %}
                    <span>{{ time[2] }}</span>
                  {% endfor %}
                </span>
              </div>
            {% endfor %}
          </div>

          <br />

          {% if listing.availability_exceptions != blank %}
            <h2>Except:</h2>

            <div class="availability-detailed-container">
              {% for exception in listing.availability_exceptions %}
                <div class='week-day'>
                  <strong>
                    {{ exception.label }}:
                  </strong>

                   <span>
                    <span>{{ exception.period }}</span>
                  </span>
                </div>
              {% endfor %}
            </div>
          {% endif %}

        </div>

        {% if listing.properties.education != blank %}
          <div class="education">
            <h2>Education:</h2>
            {{ listing.properties.education }}
          </div>
        {% endif %}

        {% if listing.properties.technical_certifications != blank %}
          <div class="technical-certifications">
            <h2>Technical Certifications</h2>
            {% assign certifications = listing.properties.technical_certifications | split: ',' %}
            {% for cert in certifications %}
            <div>- <span>{{ cert }}</span></div>
            {% endfor %}
          </div>
        {% endif %}

        {% if listing.properties.languages.size > 0 %}
          <div class="languages">
            <h2>Languages:</h2>
            <ul>
            {% assign languages = listing.properties.languages | split: ',' %}
            {% for language in languages %}
              <li>{{ language | downcase | prepend: 'service_type.ninja.languages.' | translate }}</li>
            {% endfor %}
            </ul>
          </div>
        {% endif %}

        <div class='flag-as-inappropriate'>
          <a href="#" data-href="{{ listing.inappropriate_report_path }}" data-modal="1">{{ 'inappropriate_reports.flag_as_inappropriate' | translate }}</a>
        </div>

      </div>
    </div>
  </article>
</div>
},
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/user_reservations/reservation_details',
      partial: true
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %(
<div class="row">
  <div class="col-sm-3">
    <h3> Needs Help With:</h3>
    <p>
      {% assign services = reservation.properties.service_category | split: ',' %}
      {{ services | join: ', ' }}
    </p>
  </div>

  <div class="col-sm-3">
    <h3>Date &amp; Time</h3>
    <p> {{ reservation.starts_at | localize: 'long' }}</p>
  </div>

  <div class="col-sm-3">
    <h3>Location</h3>
      {{ reservation.address.address }}
      <br />
      [ <a href="http://maps.apple.com/?q={{reservation..address.address}}" target='_blank'>{{ 'dashboard.user_reservations.show_on_map' | translate }}</a> ]
  </div>

  <div class="col-sm-1">
    <h3>{{ 'dashboard.user_reservations.total' | translate }}</h3>
    <p>
    {% if for_host %}
      {{ reservation.total_amount_for_host_if_payment_at_least_authorized }}
    {% else %}
      {{ reservation.total_amount_if_payment_at_least_authorized }}
    {% endif %}
    </p>
  </div>
</div>

<div class="row">
  <div class="col-sm-12">
    <h3>Technical Issue Description</h3>
    <p>{{ reservation.properties.technical_description }}</p>
  </div>
</div>

            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'registrations/buyer_header',
      partial: true
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %(
<h2>{{ 'sign_up_form.buyer_sign_up_to' | translate: marketplace_name: platform_context.name }}</h2>
<p class="transaction-side-switcher">Hire your own personal Ninja.</p>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'registrations/seller_header',
      partial: true
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %(
<h2>{{ 'sign_up_form.seller_sign_up_to' | translate: marketplace_name: platform_context.name }}</h2>
<p class="transaction-side-switcher">Looking to get technical help? {{ link_to_other }}</p>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'registrations/buyer_footer',
      partial: true
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %{
<p class="signup-help-note">Need help signing up? Call Member Services at <a href="tel:+18886465868">1-888-NINJUNU</a> (<a href="tel:+18886465868">1-888-646-5868</a>)</p>
      },
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'registrations/seller_footer',
      partial: true
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: %{
<p class="signup-help-note">Need help signing up? Call Member Services at <a href="tel:+18886465868">1-888-NINJUNU</a> (<a href="tel:+18886465868">1-888-646-5868</a>)</p>
      },
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)

    theme_header
    home_carousel
    home_index
    home_search_geolocation
    home_search_box_inputs
    home_search_category_multiple_choice
    home_homepage_content
    theme_footer
    search_list_listing
    wish_list_button_injection
    reservation_sidebar
    review_stars
  end

  def create_content_holders
    ch = @instance.theme.content_holders.where(
      name: 'Just Hala CSS'
    ).first_or_initialize

    ch.update!(content: "<link rel='stylesheet' media='screen' href='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/attachment_file/data/2369/just_hala.css'>",
               inject_pages: ['any_page'],
               position: 'head_bottom')

    ch = @instance.theme.content_holders.where(
      name: 'Just Hala JS'
    ).first_or_initialize

    ch.update!(content: "<script src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/attachment_file/data/2330/just_hala.js'></script>",
               inject_pages: ['any_page'],
               position: 'body_bottom')

    @instance.theme.content_holders.where(
      name: 'just_hala_temp'
    ).first.try(:destroy)
  end

  def set_theme_options
    theme = @instance.theme

    theme.color_green = '#23B6B0'
    theme.color_red = '#E44A3B'

    theme.call_to_action = 'Learn more'
    theme.phone_number = '1-888-646-5868'
    theme.contact_email = 'support@ninjunu.com'
    theme.support_email = 'support@ninjunu.com'

    theme.blog_url = nil
    theme.facebook_url = 'https://facebook.com'
    theme.twitter_url = 'https://twitter.com'
    theme.gplus_url = 'https://plus.google.com'
    theme.instagram_url = 'https://www.instagram.com'
    theme.youtube_url = 'https://www.youtube.com'
    theme.rss_url = 'rss'

    ['About', 'Careers', 'Terms of Use', 'User Agreement', 'Privacy Policy', 'FAQ', 'How It Works'].each do |name|
      slug = name.parameterize
      page = theme.pages.where(slug: slug).first_or_initialize
      page.path = name
      page.content = %(
<h2>#{name}</h2>
<p>Lorem ipsum dolor sit amet enim. Etiam ullamcorper. <strong>Suspendisse a pellentesque dui, non felis</strong>. Maecenas malesuada elit lectus felis, malesuada ultricies. Curabitur et ligula. Ut molestie a, ultricies porta urna. Vestibulum commodo volutpat a, convallis ac, laoreet enim. Phasellus fermentum in, dolor. <strong>Pellentesque facilisis. Nulla imperdiet sit amet magna.</strong> Vestibulum dapibus, mauris nec malesuada fames ac turpis velit, rhoncus eu, luctus et interdum adipiscing wisi. Aliquam erat ac ipsum. Integer aliquam purus. Lorem ipsum dolor sit amet enim. Etiam ullamcorper. Suspendisse a pellentesque dui, non felis. Maecenas malesuada elit lectus felis, malesuada ultricies. <strong>Curabitur et ligula. Ut molestie a, ultricies porta urna</strong>. Vestibulum commodo volutpat a, convallis ac, laoreet enim. </p>
<ul>
  <li> Pellentesque facilisis</li>
  <li>Curabitur et ligula</li>
  <li>Curabitur et ligula</li>
</ul>
<p>Lorem ipsum dolor sit amet enim. Etiam ullamcorper. Suspendisse a pellentesque dui, non felis. Maecenas malesuada elit lectus felis, malesuada ultricies. Curabitur et ligula. Ut molestie a, ultricies porta urna. Vestibulum commodo volutpat a, convallis ac, laoreet enim. Phasellus fermentum in, dolor. <strong>Pellentesque facilisis. Nulla imperdiet sit amet magna.</strong> Vestibulum dapibus, mauris nec malesuada fames ac turpis velit, rhoncus eu, luctus et interdum adipiscing wisi. </p>

)
      page.remote_hero_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2337/page-header.jpg'
      page.save!
    end

    theme.updated_at = Time.now

    begin
      theme.save!
    rescue
      puts "Validation failed! #{theme.pages.map { |p| p.valid?; [p.path, p.slug, p.errors.full_messages.join(', ')] } }"
      raise 'Fail'
    end
  end

  def upload_logo_images
    theme = @instance.theme
    theme.remote_logo_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/images/theme/logo_image/413/transformed_ninjunu_logo.png'
    theme.remote_logo_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/images/theme/logo_image/413/transformed_ninjunu_logo.png'
    theme.remote_icon_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/images/theme/icon_image/413/transformed_ninjunu_icon.png'
    theme.remote_icon_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/images/theme/icon_image/413/transformed_ninjunu_icon.png'

    theme.save!
  rescue
  end

  def create_translations
    transformation_hash = {
      'reservation' => 'mission',
      'Reservation' => 'Mission',
      'booking' => 'mission',
      'Booking' => 'Mission',
      'host' => 'Ninja',
      'Host' => 'Ninja',
      'guest' => 'Client',
      'Guest' => 'Client',
      'this listing' => 'your Ninja Profile',
      'that listing' => 'your Ninja Profile',
      'This listing' => 'Your Ninja Profile',
      'That listing' => 'Your Ninja Profile',
      'listing' => 'Ninja Profile'
    }
    (Dir.glob(Rails.root.join('config', 'locales', '*.en.yml')) + Dir.glob(Rails.root.join('config', 'locales', 'en.yml'))).each do |yml_filename|
      en_locales = YAML.load_file(yml_filename)
      en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])
      en_locales_hash.each_pair do |key, value|
        next if value.blank?
        new_value = value
        transformation_hash.keys.each do |word|
          new_value = new_value.gsub(word, transformation_hash[word])
        end
        if value != new_value
          t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: @instance.id)
          t.value = new_value
          t.skip_expire_cache = true
          t.save!
          puts "\t\tTranslation updated: key: #{key}, value: #{value} -> #{t.value}"
        end
      end
    end
    @instance.translations.where(
      locale: 'en',
      key: 'sign_up_form.buyer_sign_up_to'
    ).first_or_initialize.update!(value: 'Sign Up for Ninjunu')

    @instance.translations.where(
      locale: 'en',
      key: 'sign_up_form.seller_sign_up_to'
    ).first_or_initialize.update!(value: 'Create a Ninja Account')

    @instance.translations.where(
      locale: 'en',
      key: 'ui.header.list_your_thing'
    ).first_or_initialize.update!(value: 'Become a Ninja')

    @instance.translations.where(
      locale: 'en',
      key: 'registrations.accept_terms_of_service'
    ).first_or_initialize.update!(value: 'Yes, I understand and agree to <a href="/terms-of-use" target="_blank">Terms of Service</a> including the <a href="/user-agreement" target="_blank">User Agreement</a> and <a href="/privacy-policy" target="_blank">Privacy Policy</a>')

    @instance.translations.where(
      locale: 'en',
      key: 'onboarding_wizard.list_your'
    ).first_or_initialize.update!(value: 'Complete Your Ninja Profile')

    @instance.translations.where(
      locale: 'en',
      key: 'simple_form.labels.locations.name'
    ).first_or_initialize.update!(value: 'Name Your Location')

    @instance.translations.where(
      locale: 'en',
      key: 'simple_form.hints.location.name'
    ).first_or_initialize.update!(value: 'Name the location to something like - My Home or My Office')

    @instance.translations.where(
      locale: 'en',
      key: 'simple_form.labels.locations.location_address.address'
    ).first_or_initialize.update!(value: 'Your Address')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.labels.name'
    ).first_or_initialize.update!(value: 'Your Ninja Name')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.items.listing_published'
    ).first_or_initialize.update!(value: 'Master Availability')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.labels.description'
    ).first_or_initialize.update!(value: 'Profile Description')

    @instance.translations.where(
      locale: 'en',
      key: 'simple_form.hints.listings.description'
    ).first_or_initialize.update!(value: 'This will appear on your profile as About Me')

    @instance.translations.where(
      locale: 'en',
      key: 'pricing.price'
    ).first_or_initialize.update!(value: 'Hourly Rate')

    @instance.translations.where(
      locale: 'en',
      key: 'pricing.price_unit.person_hour'
    ).first_or_initialize.update!(value: 'Per Hour')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.labels.technical_certifications'
    ).first_or_initialize.update!(value: 'Enter Technical Certifications')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.hints.technical_certifications'
    ).first_or_initialize.update!(value: 'e.g. Apple Certified Technician, MCSE, MCSD 2')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.labels.service_area'
    ).first_or_initialize.update!(value: 'Describe Your Service Area')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.valid_values.languages.english'
    ).first_or_initialize.update!(value: 'English')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.valid_values.languages.french'
    ).first_or_initialize.update!(value: 'French')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.valid_values.languages.german'
    ).first_or_initialize.update!(value: 'German')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.valid_values.languages.spanish'
    ).first_or_initialize.update!(value: 'Spanish')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.english'
    ).first_or_initialize.update!(value: 'I speak English')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.german'
    ).first_or_initialize.update!(value: 'Ich spreche Deutsch')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.french'
    ).first_or_initialize.update!(value: 'Je parle français')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.spanish'
    ).first_or_initialize.update!(value: 'Yo hablo español')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.chinese'
    ).first_or_initialize.update!(value: '我說中國')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.tagalog'
    ).first_or_initialize.update!(value: 'Nagsasalita ako ng Tagalog')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.vietnamese'
    ).first_or_initialize.update!(value: 'Tôi nói tiếng Việt nam')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.korean'
    ).first_or_initialize.update!(value: '저는 한국말 할줄 알아요')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.farsi'
    ).first_or_initialize.update!(value: 'من فارسی حرف می زنم')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.russian'
    ).first_or_initialize.update!(value: 'Я говорю по русски')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.arabic'
    ).first_or_initialize.update!(value: 'اتحدث العربية')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.italian'
    ).first_or_initialize.update!(value: 'Parlo italiano')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.languages.polish'
    ).first_or_initialize.update!(value: 'Mówię po polsku')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.labels.conditions'
    ).first_or_initialize.update!(value: 'Do You Have Any Conditions ?')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.hints.conditions'
    ).first_or_initialize.update!(value: 'e.g I am allergic to pets')

    @instance.translations.where(
      locale: 'en',
      key: 'service_type.ninja.hints.video_url'
    ).first_or_initialize.update!(value: 'this links to your Ninja Video on Youtube or Vimeo')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.user_reservations'
    ).first_or_initialize.update!(value: 'My Missions')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.reviews'
    ).first_or_initialize.update!(value: 'Ratings')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.host_reservations'
    ).first_or_initialize.update!(value: 'My Missions')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.edit'
    ).first_or_initialize.update!(value: 'Account')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.transactables'
    ).first_or_initialize.update!(value: 'My Ninja Profile')

    @instance.translations.where(
      locale: 'en',
      key: 'top_navbar.my_bookings'
    ).first_or_initialize.update!(value: 'My Missions')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.user_reservations.reservation_placed_html'
    ).first_or_initialize.update!(value: 'Mission created: <span>%{date}</span>')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.analytics.bookings'
    ).first_or_initialize.update!(value: 'Missions')

    create_translation!('dashboard.user_reservations.title_count', 'Missions (%{count})')

    create_translation!('general.generic_lessee_term', 'client')

    create_translation!('dashboard.host_reservations.no_unconfirmed_reservations', 'You have no unconfirmed missions.')
    create_translation!('dashboard.host_reservations.no_confirmed_reservations', 'You have no confirmed missions.')
    create_translation!('dashboard.host_reservations.no_archived_reservations', 'You have no archived missions.')
    create_translation!('dashboard.host_reservations.no_overdue_reservations', 'You have no overdue missions.')
    create_translation!('dashboard.host_reservations.no_reservations_promote_reservations', 'You currently have no missions.')

    create_translation!('dashboard.analytics.no_reservations_yet', 'You currently do not have any missions.')

    create_translation!('simple_form.labels.transactable.confirm_reservations', 'Manually confirm missions')

    create_translation!('dashboard.nav.user_reservations_count_html', 'My Missions <span>%{count}</span>')

    create_translation!('dashboard.analytics.columns.bookings', 'Missions')
    create_translation!('dashboard.analytics.total.bookings', '%{total} missions')

    create_translation!('dashboard.host_reservations.pending_confirmation', 'You must confirm this mission within <strong>%{time_to_expiry}</strong> or it will expire.')

    create_translation!('dashboard.transactables.title.listings', 'Ninja Profile')
    create_translation!('dashboard.manage_listings.tab', 'Ninja Profile')

    create_translation!('dashboard.user_reservations.upcoming', 'Missions Open')
    create_translation!('dashboard.user_reservations.archived', 'Missions Closed')

    create_translation!('dashboard.host_reservations.unconfirmed', 'Missions Pending')
    create_translation!('dashboard.host_reservations.confirmed', 'Missions Open')
    create_translation!('dashboard.host_reservations.archived', 'Missions Closed')

    create_translation!('reservations.states.unconfirmed', 'Pending')
    create_translation!('reservations.states.confirmed', 'Open')
    create_translation!('reservations.states.archived', 'Closed')
    create_translation!('reservations.states.cancelled_by_guest', 'Cancelled by Client')
    create_translation!('reservations.states.cancelled_by_host', 'Cancelled by Ninja')

    create_translation!('top_navbar.manage_bookable', 'My Ninja Profile')
    create_translation!('top_navbar.bookings_received', 'My Missions')
    create_translation!('reservations_review.heading', 'Book a Mission')

    create_translation!('reservations_review.errors.whoops', "Whoops! We couldn't book that mission.")

    create_translation!('reservations_review.errors.does_not_work_on_date', "Unfortunately, this ninja doesn't offer services during the time you requested.")

    create_translation!('activemodel.errors.models.reservation_request.attributes.base.total_amount_changed', 'Book a Mission')
    create_translation!('dashboard.items.new_listing_full', 'Create Ninja Profile')

    create_translation!('reservations_review.disabled_buttons.request', 'Hiring...')
    create_translation!('dashboard.transactables.view_html', 'View Profile')

    create_translation!('buy_sell_market.products.labels.summary', 'Overall Rating:')
    create_translation!('dashboard.items.delete_listing', 'Delete Ninja Profile')

    create_translation!('sign_up_form.link_to_buyer', 'Become a member here')
    create_translation!('sign_up_form.link_to_seller', 'Become a ninja here')

    create_translation!('time.formats.short', '%l:%M %p')

    create_translation!('wish_lists.buttons.selected_state', 'Favorite')
    create_translation!('wish_lists.buttons.unselected_state', 'Favorite')

    create_translation!('flash_messages.reservations.credit_card_will_be_charged', 'Your credit card will be charged when mission is completed.')
    create_translation!('flash_messages.space_wizard.space_listed', 'Your ninja profile has been submitted to the marketplace for approval. Please watch for a message indicating that your profile has been approved, at which time you’ll be ready for Ninjunu tech missions!')

    create_translation!('flash_messages.dashboard.locations.add_your_company', 'Please complete your Ninja Profile first.')
    create_translation!('flash_messages.dashboard.add_your_company', 'Please complete your Ninja Profile first.')
  end

  # Liquid view: Layouts > Theme Header
  def theme_header
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'layouts/theme_header',
      partial: true
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<div class='navbar navbar-inverse navbar-fixed-top'>
    <div class='navbar-inner nav-links'>
      <div class='container-fluid'>
          <a href='{{ platform_context.root_path }}' id="logo">{{ platform_context.name }}</a>
          {% if no_header_links == false %}
              <div id='header_links' class='links-container pull-right'>
                <ul class="nav main-menu header-custom-links">
                  <li>
                    <a href='/' class='nav-link'>
                      <span class='text'>Home</span>
                    </a>
                  </li>

                  <li>
                    <a href='/how-it-works' class='nav-link'>
                      <span class='text'>How It Works</span>
                    </a>
                  </li>
                </ul>
                  {{ navigation_links | make_html_safe }}
              </div>
          {% endif %}
      </div>
    </div>
</div>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Carousel
  def home_carousel
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/carousel'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<div class='homepage-carousel carousel slide'>
  <div class='carousel-inner' role='listbox'>
    <div class='item active slide-01' data-slogan='Tech-savvy, anywhere, anytime'></div>
    <div class='item slide-02' data-slogan='IT support for small business'></div>
    <div class='item slide-03' data-slogan='Technology for all generations'></div>
    <div class='item slide-04' data-slogan='Technology for the people'></div>
  </div>
</div>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Index
  def home_index
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/index'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
{% content_for 'hero' %}
  {% include 'home/carousel.html' %}

  <div class="container-fluid">
    <div class="row-fluid">
      {% if platform_context.is_company_theme? %}
        {% include 'home/search_button.html' %}
      {% else %}
        {% include 'home/search_box.html' %}
      {% endif %}
    </div>
  </div>

  <div class="call-to-action">
    <a data-call-to-action="true">
      {{platform_context.call_to_action}}
      <br/>
      <span class="ico-chevron-down"></span>
    </a>
  </div>
{% endcontent_for %}

{% include 'home/homepage_content.html' %}
            ),
               format: 'html',
               handler: 'liquid',
               partial: false,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Search > Geolocation
  def home_search_geolocation
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/search/geolocation'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<div class="{{ transactable_type.calculate_input_size }} search-field-wrapper">
  <input class="query" name="loc" placeholder="{{ transactable_type.geolocation_placeholder }}" type="text" />
</div>
<input id="lat" name="lat" type="hidden" value>
<input id="lng" name="lng" type="hidden" value>
<input id="nx" name="nx" type="hidden" value>
<input id="ny" name="ny" type="hidden" value>
<input id="sx" name="sx" type="hidden" value>
<input id="sy" name="sy" type="hidden" value>
<input id="country" name="country" type="hidden" value>
<input id="state" name="state" type="hidden" value>
<input id="city" name="city" type="hidden" value>
<input id="suburb" name="suburb" type="hidden" value>
<input id="street" name="street" type="hidden" value>
<input id="postcode" name="postcode" type="hidden" value>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Search Box Inputs
  def home_search_box_inputs
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/search_box_inputs'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<form action="/search" class="home_search search-box {{ class_name }}" method="get">
  <div class="input-wrapper">

    <div class="row-fluid">
      {% for transactable_type in transactable_types %}
        <div class="transactable-type-search-box" data-transactable-type-id="{{ transactable_type.select_id }}" {% if forloop.first != true %} style=" display: none;" {% endif%}>
          <h1 class='slogan'>Tech-savvy, anywhere, anytime</h1>
          <h2><span>Hire your own local tech ninja</span></h2>
          <p>select help category:</p>

          {% assign custom_search_inputs = 'category_multiple_choice,geolocation' | split: ',' %}
          {% for input in transactable_type.search_inputs %}
            {% assign input_path = input | prepend: 'home/search/' %}
            {% include input_path %}
          {% endfor %}

        </div>
      {% endfor %}
      {% if transactable_types.size > 1 %}
        {% if platform_context.tt_select_type == 'dropdown' %}
          <div class="span2">
            <select class="no-icon select2 transactable_select" data-transactable-type-picker name="transactable_type_selector">
              {% for transactable_type in transactable_types %}
                <option value="{{ transactable_type.select_id }}">{{ transactable_type.name }}</option>
              {% endfor %}
            </select>
          </div>
        {% endif %}
      {% endif %}
      <input name="transactable_type_id" type="hidden" value="{{ transactable_type.id }}">

      <div class="span2 pull-right submit-button-wrapper">
        <a class="btn btn-green btn-large search-button" data-disable-with="{{ 'homepage.disabled_buttons.search' | translate }}" rel="submit" href="">
          <span class="ico-search"></span>
          {{ 'homepage.buttons.search' | translate }}
        </a>
        <div id="suggest_location" style="display: none"></div>
      </div>
    </div>
    {% if transactable_types.size > 1 and platform_context.tt_select_type == 'radio' %}
      <div class="row-fluid">
        <div class="span10">
          <div class="search-transactable--radio">
            {% for transactable_type in transactable_types %}
            <label for="transactable-type-{{ transactable_type.id }}">
            <input type="radio" name="transactable_type_selector" value="{{ transactable_type.select_id }}" id="transactable-type-{{ transactable_type.id }}" {% if forloop.first == true %} checked {% endif %} data-transactable-type-picker > {{ transactable_type.name}}</label>
            {% endfor %}
          </div>
        </div>
      </div>
    {% endif %}
  </div>
  <input type="hidden" name="transactable_type_class">
  <input type="submit"/>
</form>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Search > Category Multiple Choice
  def home_search_category_multiple_choice
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/search/category_multiple_choice'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<div class='category-multiple-choice'>
  {% for root_category in transactable_type.searchable_categories %}
    {% for category in root_category.children %}
      <div class='category'>
        <input type='checkbox' value="{{ category.id }}" name='category_ids[]' id='category-{{ category.id }}' />
        <label for='category-{{ category.id }}'>
          <span aria-hidden="true" class="icon">

          {% if category.name == 'Mac' %}
          <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110"> <path d="M75.2,67.1c0,0-3,8-6.3,10.8c-3.3,2.8-4.3,3.5-7.1,2.7c-2.9-0.8-4.7-2.3-7.6-1.9c-2.9,0.4-5.3,2.2-7.8,2.2 c-2.4-0.1-5.8-2.2-9.2-8C34,67.2,32.2,59.8,33,53.9c0.8-5.8,5.3-10.7,9.5-11.8C48.7,40.6,51,44,54.3,44c0,0,1.1,0,3.3-0.9 c2.2-0.9,4.5-2.2,8.9-1.2c4.5,1,7.1,4.8,7.1,4.8s-6.8,4.2-5.4,11.4C69.7,65.3,75.2,67.1,75.2,67.1z M62,37.2C65.1,34,64,29,64,29 s-4.4,0.8-7.4,3.9c-3,3.1-2.5,8-2.5,8S58.8,40.5,62,37.2z"/> </svg>
          {% endif %}

          {% if category.name == 'PC' %}
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110"> <path d="M30,53.3l0-16.3l20-2.7v19H30z M53.3,33.9L80,30v23.3H53.3V33.9z M80,56.7L80,80l-26.7-3.8V56.7H80z M50,75.8l-20-2.7 l0-16.4h20V75.8z M50,75.8"/> </svg>
          {% endif %}

          {% if category.name == 'Mobile' %}
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110"> <path d="M68.8,24H41.2c-2.5,0-4.6,2-4.6,4.6v52.9c0,2.5,2,4.6,4.6,4.6h27.5c2.5,0,4.6-2,4.6-4.6V28.6 C73.3,26,71.3,24,68.8,24z M51.4,27.9h7.2c0.6,0,1.1,0.5,1.1,1.1c0,0.6-0.5,1.1-1.1,1.1h-7.2c-0.6,0-1.1-0.5-1.1-1.1 C50.3,28.4,50.8,27.9,51.4,27.9z M55,82.8c-1,0-1.9-0.8-1.9-1.9c0-1,0.8-1.9,1.9-1.9c1,0,1.9,0.8,1.9,1.9C56.9,82,56,82.8,55,82.8z M71.1,76.3H38.9V34.1h32.2V76.3z"/> </svg>
          {% endif %}

          {% if category.name == 'Training' %}
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110"> <path d="M46.8,49.7c0,2.7-2.2,5-5,5c-2.7,0-5-2.2-5-5c0-2.7,2.2-5,5-5C44.6,44.7,46.8,46.9,46.8,49.7z M82.4,34.5H27.6 c-0.8,0-1.5,0.7-1.5,1.5v38.8c0,0.8,0.7,1.5,1.5,1.5h19.2v-0.7h0V59.6h10.7c0.7,0,1.3-0.8,1.3-1.8v-0.5c0-1-0.6-1.8-1.3-1.8H46.8 h-0.2h-3.4l-1.4,2.4l-1.4-2.4h-3.1h-0.1h-0.4c-1.1,0-2,0.6-2,1.3v13.4c0,0.7,0.9,1.3,2,1.3h0.4v1.2h-8V38.2h51.5v34.4H58.1v3.7h24.3 c0.8,0,1.5-0.7,1.5-1.5v0V36C84,35.2,83.3,34.5,82.4,34.5z"/> </svg>
          {% endif %}

          </span>
          <span class="category-name">{{ category.name }}</span>
        </label>
      </div>
    {% endfor %}
  {% endfor %}
</div>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Home Page Content
  def home_homepage_content
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/homepage_content'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %{
<section id='how-it-works' class='how-it-works'>
  <div class='container-fluid'>
    <div class='row-fluid'>
      <h2>How It Works</h2>
    </div>

    <div class='row-fluid table-row'>
      <div class='teaser-wrapper table-cell'>
        <div class='span4 teaser'>
          <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2322/callout-01.jpg' />

          <div class='teaser-content'>
            <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2211/icon_ninjas.png' /></div>
            <h3>Meet Local Tech Ninjas</h3>
            <p>
              We <strong>connect individuals and small businesses with skilled ninjas</strong> who provide personalized tech support and training.
            </p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='span4 teaser'>
          <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2323/callout-02.jpg' />
          <div class='teaser-content'>
            <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2212/icon_work.png' /></div>
            <h3>Tech Experts Find Work</h3>
            <p>
              We <strong>create job opportunities for local tech ninjas</strong> by matching them with the right people who need professional experise.
            </p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='span4 teaser'>
          <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2324/callout-03.jpg' />
          <div class='teaser-content'>
            <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2214/icon_solutions.png' /></div>
            <h3>Expert Solutions</h3>
            <p>
              A ninja accomplishes the client's tech mission, allowing individuals and small businessesn the <strong>time to focus on what they do best.</strong>
            </p>
          </div>
        </div>
      </div>
    </div>

    <div class="how-it-works-cta"><a href="/how-it-works" class="btn btn-green btn-large">Learn More</a></div>

    <div class='row-fluid'>
      <div class='video-wrapper'>
        <iframe src="https://player.vimeo.com/video/27244727?color=ffffff" width="100%" height="300" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      </div>
    </div>
  </div>
</section>

<section class='what-is-ninjunu'>
  <div class='container-fluid'>
    <div class='row-fluid'>
      <h2>What is Ninjunu?</h2>
    </div>

    <div class='row-fluid'>
      <div class='span4 teaser'>
        <div class='teaser-content'>
          <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2205/it_professionals.png' /></div>
          <h3>Vetted IT Professionals</h3>
          <p>
            Introducing vetted, background checked technical ninjas
          </p>
        </div>
      </div>
      <div class='span4 teaser'>
        <div class='teaser-content'>
          <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2206/community.png' /></div>
          <h3>Community</h3>
          <p>
            Connect directly with ninjas, individuals and small businesses in your immediete community
          </p>
        </div>
      </div>
      <div class='span4 teaser'>
        <div class='teaser-content'>
          <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2207/training.png' /></div>
          <h3>Training</h3>
          <p>
            You, too, can be a tech ninja!
          </p>
        </div>
      </div>
    </div>

    <div class='row-fluid table-row'>
      <div class='span4 teaser'>
        <div class='teaser-content'>
          <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2208/transactions.png' /></div>
          <h3>Safe Online Transactions</h3>
          <p>
            We support the entire financial transaction so cash is never exchanged between parties
          </p>
        </div>
      </div>
      <div class='span4 teaser'>
        <div class='teaser-content'>
          <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2209/reviews.png' /></div>
          <h3>Helpful Reviews</h3>
          <p>
            Read reviews from your local community about ninjas serving your area
          </p>
        </div>
      </div>
      <div class='span4 teaser'>
        <div class='teaser-content'>
          <div class='image'><img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2210/support.png' /></div>
          <h3>Technical Support</h3>
          <p>
            Ninjunu is the matchmaker of technical support, offering personalized on-demand support
          </p>
        </div>
      </div>
    </div>
  </div>

</section>

<section class='find-out'>

  <div class='container-fluid'>
    <div class='row-fluid'>
      <h2>Find out why people<br><span class='love'>love</span> Ninjunu!</h2>
    </div>
    <div class='row-fluid'>
      <h3>Here's what our cusotmers have to say:</h3>
    </div>

    <div class='row-fluid table-row'>
      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>

          <div class='teaser-content'>
            <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2332/sam-benning.jpg' alt="Sam Benning">
            <p>
              A a small business owner, Ninjunu was able to provide me quick tech solutions to keep my business running. Quick and convenient!!!
            </p>

            <p class='author'>SAM BENNING</p>
            <p class='job-title'>Financial Solutionis</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2331/kara-jones.jpg' alt="Kara Jones">
            <p>
              I'm great at running my Cafe, but when it comes to internet, networking and computers, I need help. Ninjunu saved the day!
            </p>

            <p class='author'>KARA JONES</p>
            <p class='job-title'>Cafe Express</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2327/chris-ronell.jpg' alt="Chris Ronell">
            <p>
              I use my mobile phone for everything I do. I found a ninja online and they fixed and backed up my phone right away. This service is priceless :)
            </p>

            <p class='author'>CHRIS RONELL</p>
            <p class='job-title'>Enterpreneur</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
      },
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Theme > Footer
  def theme_footer
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'layouts/theme_footer',
      partial: true
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<footer>
  <div class="row-fluid">

      <div class='span3 description'>
        <a href="{{ platform_context.root_path }}" class="logo-icon">{{ platform_context.name }}</a>
        <p>
          We connect individuals and small businesses with local technical experts who can research, diagnose, and solve all kinds of technical issues.
        </p>
      </div>

      <div class='span2 general'>
        <h5>General</h5>

        <ul class="pages">
          {% for page in platform_context.pages %}
            <li><a href="{{ page.page_url }}" target="{{ page.open_in_target }}" rel="{{ page.link_rel }}">{{ page.title }}</a></li>
          {% endfor %}

        </ul>
      </div>

      <div class="span2 connect">
        <h5>Connect</h5>
        <div class="social-wrapper">
          <ul class="social-icons">
            {% if platform_context.facebook_url != blank %}<li><a href="{{ platform_context.facebook_url }}"  ref="nofollow" target="_blank"><span class="image icon-facebook"></span>Facebook</a></li>{% endif %}
            {% if platform_context.twitter_url != blank %}<li><a href="{{ platform_context.twitter_url }}" ref="nofollow"  target="_blank"> <span class="image icon-twitter"></span>Twitter</a></li>{% endif %}
            {% if platform_context.youtube_url != blank %}<li><a href="{{ platform_context.youtube_url }}" ref="nofollow"  target="_blank"> <span class="image icon-youtube"></span>Youtube</a></li>{% endif %}
            {% if platform_context.gplus_url != blank %}<li><a href="{{ platform_context.gplus_url }}" rel="publisher nofollow" target="_blank"><span class="image icon-gplus"></span>Google+</a></li>{% endif %}
            {% if platform_context.instagram_url != blank %}<li><a href="{{ platform_context.instagram_url }}" ref="nofollow"  target="_blank"> <span class="image icon-instagram"></span>Instagram</a></li>{% endif %}
            {% if platform_context.rss_url != blank %}<li><a href="{{ platform_context.rss_url }}" rel="nofollow" target="_blank"><span class="image icon-rss"></span>Blog</a></li>{% endif %}
            {% if platform_context.blog_url != blank %}<li><a href="{{ platform_context.blog_url }}" rel="nofollow" target="_blank"><span class="image ico-blog"></span>Blog</a></li>{% endif %}
          </ul>
        </div>
      </div>

      <div class="span2 contact">
        <h5>Contact</h5>
        <div class='phone'>TELEPHONE</div>
        <span>1-888-NINJUNU<br>{{ platform_context.phone_number }}</span>
        <div class='support'>SUPPORT</div>
        <a href='mailto:{{ platform_context.support_email }}'>{{ platform_context.support_email }}</a><br />
      </div>
    </div>

    <div class='copyright-wrapper'>
      <div class='copyright'>
        &copy; 2016 Ninjunu. All rights reserved.
      </div>
    </div>

</footer>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Search > List > Listing
  def search_list_listing
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'search/list/listing'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %{
<article class='listing' data-id="{{listing.id}}" data-name="{{listing.name}}" data-latitude="{{listing.latitude}}" data-longitude="{{listing.longitude}}" data-location-href="{{ listing.url }}">
  <header>
    {% if listing.has_photos? %}
      {% assign photo_class = '' %}
    {% else %}
      {% assign photo_class = 'without-photos' %}
    {% endif %}

    <div class="photo">
      <a href='{{ listing.url }}'>
        <img src="{{ listing.photo_url }}" title="{{ listing.name }}" alt="{{ listing.name }}" />
      </a>
    </div>

    {% include 'shared/components/wish_list_button_injection.html', object: listing %}
  </header>

  <div class='content'>
    <h3 class='username'>{{ listing.name | filter_text | custom_sanitize }}</h3>
    <div class='details'>
      <div class='missions-count'><span>Missions:</span> {{ listing.creator.completed_host_reservations_count }}</div>
      <div class='review-stars'>
        <span class='details-label'>Rating:</span>
        <span class='star-container'>
          {% for i in (1..listing.creator.seller_average_rating) %}
            <img src="https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2277/star_on.png" />
          {% endfor %}
          {% for i in (listing.creator.seller_average_rating..4) %}
            <img src="https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2278/star_off.png" />
          {% endfor %}
        </span>
      </div>
      <div class='address'>
        <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2279/location_marker.png' />
        <span>{{ listing.location.address }}</span>
      </div>
    </div>
    <div class='description'>
      {{ listing.description | truncatewords:150 }}
      <a href='{{ listing.url }}'>See more details</a>
    </div>
  </div>

  <footer>
    <div class="hire-me">
      <form id="reservation_request_form_{{ listing.id }}" novalidate="novalidate" class="reservation_request" action="{{ 'review_listing_reservations_path' | generate_url: listing }}" accept-charset="UTF-8" method="post">
        <input name="utf8" type="hidden" value="">
        <input name="authenticity_token" value="{{ form_authenticity_token }}" data-authenticity-token type="hidden">
        <input type="hidden" name="reservation_request[booking_type]" id="reservation_request_booking_type" value="hourly">
        <input type="submit" value="Hire Me!">
      </form>
    </div>

    <div class="price">
      {% assign price_info = listing | lowest_price_without_cents_with_currency %}
      {% if price_info.price %}
      <span>{{ price_info.price}} <span class='period'>/hr</span></span>
      {% elsif price_info.free %}
      <span>{{ 'search.free_listing' | translate }}</span>
      {% endif %}
    </div>

    <div class='categories'>
      {% for category in listing.transactable_type.categories["Services"]["children"] %}
          {% assign is_included = listing.categories["Services"]["children"] | is_included_in_array: category %}
          {% if is_included %}
            {% assign div_class = "included" %}
          {% else %}
            {% assign div_class = "" %}
          {% endif %}
          <div class='category {{div_class}}'>
            <span>{{ category }}</span>
          </div>
        {% endfor %}
    </div>
  </footer>
</article>
      },
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  # Liquid view: Home > Search > Category Multiple Choice

  def wish_list_button_injection
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'shared/components/wish_list_button_injection'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %{
<div data-add-favorite-button="true" data-path="{{ object.wish_list_path }}", data-object-type="{{ object.class_name }}" data-link-to-classes="{{ link_to_classes}}">
  <div class="text-center"><img src="{{ 'components/modal/loader.gif' | image_url }}" /></div>
</div>

<script>$(document).trigger('load:favoritebutton.nearme');</script>
      },
               format: 'html',
               handler: 'liquid',
               partial: false,
               view_type: 'view',
               locales: Locale.all)
  end

  def reservation_sidebar
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'listings/reservations/sidebar'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %(
<aside>
  <div class='sidebar-wrapper'>
    <header>
      <h3>Simple steps</h3>
      <p>Here's what happens next</p>
    </header>

    <div class='step'>
      1. The Ninja will get in touch with you within 30 minutes. Please keep your mobile phone on or watch your Ninjunu mailbox.
    </div>

    <div class='step'>
      2. Your technical issues will be resolved.
    </div>

    <div class='step'>
      3. Your credit card will be charged after the mission is completed.
    </div>

    <div class='need-help step'>
      <h3>Need Help?</h3>
      <strong>Call: {{ platform_context.phone_number }}</strong>
    </div>
  </div>
</aside>
            ),
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  def review_stars
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'buy_sell_market/products/stars'
    ).first_or_initialize

    iv.update!(transactable_types: TransactableType.all,
               body: %{
<span class='star-container'>
  {% for i in (1..stars) %}
    <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2277/star_on.png' />
  {% endfor %}
  {% for i in (stars..4) %}
    <img src='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/picture/data/2278/star_off.png' />
  {% endfor %}
</span>

{% if count != blank %}
  <a>{{count}})</a>
{% endif %}
      },
               format: 'html',
               handler: 'liquid',
               partial: true,
               view_type: 'view',
               locales: Locale.all)
  end

  def create_workflow_alerts
    WorkflowStep.where(associated_class: ['WorkflowStep::ReservationWorkflow::OneDayToBooking',
                                          'WorkflowStep::ReservationWorkflow::OneBookingSuggestions',
                                          'WorkflowStep::ListingWorkflow::Created'
                                         ]).find_each do |ws|
      ws.workflow_alerts.destroy_all
    end
    WorkflowAlert.find_by(id: 14_364).try(:destroy)
    @reservation_creator = Utils::DefaultAlertsCreator::ReservationCreator.new
    @reservation_creator.notify_host_of_approved_payment!
    @reservation_creator.notify_host_of_declined_payment!
    @reservation_creator.notify_guest_of_submitted_checkout!
    @reservation_creator.notify_guest_of_submitted_checkout_with_failed_authorization!
    @user_creator = Utils::DefaultAlertsCreator::SignUpCreator.new
    @user_creator.create_guest_welcome_email!
    @user_creator.create_host_welcome_email!

    create_email('post_action_mailer/host_sign_up_welcome', %(
<h2>Welcome, {{ user.first_name }}!</h2>

<p>We are excited to welcome you to {{ platform_context.name }}!</p>

<p><strong>Offer your Ninja Technical Skills </strong> – reduce overhead, expand your networks and access tools to easily manage your clients and payments.</p>

<p>Easy, right?</p>
<p><a class="btn" href="{{ platform_context.host | append:user.space_wizard_list_url_with_tracking | append:signature_for_tracking }}">Create your Ninja Profile</a>.</p>

<p>I love hearing from our members; if you have any questions or feedback for me, please send me through a reply.</p>

<p>Cheers,</p>
<p>{{ platform_context.name }}</p>
                                  ))

    create_email('post_action_mailer/guest_sign_up_welcome', %(
<h2>Welcome, {{ user.first_name }}!</h2>

<p>We are excited to welcome you to {{ platform_context.name }}!</p>

<p><strong>Find the perfect Ninja</strong> – we'll help you find the right Ninja for you. <i>To us the perfect {{ platform_context.bookable_noun }} means the perfect experience too. We're working hard to make sure you have a great experience once you've arrived at your {{ platform_context.bookable_noun }}.</i></p>

<p>Easy, right? Start searching now!</p>
<p><a class="btn" href="{{ platform_context.host | append:user.search_url_with_tracking | append:signature_for_tracking }}">Find Ninja</a></p>
<p>I love hearing from our members; if you have any questions or feedback for me, please send me through a reply.</p>

<p>Cheers,</p>
<p>{{ platform_context.name }}</p>
                                  ))

    create_email('reservation_mailer/notify_host_of_expiration', %(
<h2>Can we help, {{ user.first_name }}?</h2>

<p>We noticed that you didn't confirm {{ reservation.owner.first_name }}'s mission at {{ reservation.address.address }} within the required 24 hour period.</p>

<p>That's one missed opportunity but we're here to help so you don’t miss any other missions!</p>

<p>Please, let us know if you are is still available. Also don't forget to update your contact information in your personal account so Clients can reach you easily.</p>

<a class="btn" href="{{ platform_context.host | append:user.edit_user_registration_url_with_token_and_tracking | append:signature_for_tracking }}">Go to My Account</a>

          ))

    create_email('post_action_mailer/list_draft', %(
<h2>Heads up, {{ user.first_name }}!</h2>

<p>There are people looking for your skills in your area. Finish your Ninja Profile and get clients; it won't take long, we promise!</p>

<a class="btn" href="{{ platform_context.host | append:user.space_wizard_list_url_with_tracking | append:signature_for_tracking }}">Finish Your Ninja Profile</a>

<p>We are here to help! If you have any questions, or need inspiration to complete your listing, please send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a> {{ platform_context.phone_number }}.</p>

          ))

    create_email('reservation_mailer/notify_guest_of_cancellation_by_host', %(
<h2>Change of plans, {{ user.first_name }}!</h2>

<p>The mission has been cancelled by the <a href="{{ listing.show_url }}">{{platform_context.lessor}}</a>.</p>

<p>No worries! You can always find other Ninjas in your area.</p>

<a class="btn" href="{{ platform_context.host | append:listing.search_url_with_tracking | append:signature_for_tracking  }}">Search More Ninja</a>

<p>We're always happy to help! Just send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>

          ))

    create_email('reservation_mailer/notify_guest_of_confirmation', %(

<h2>You got it, {{ user.first_name }}!</h2>

<p>Your mission has been confirmed by the Ninja! Here it is:</p>

<div class="booking-details">

  <div class="row">
    <strong style='display: inline-block;'>{{platform_context.lessor | capitalize}}</strong>
    <span style="float: right;"><a href="{{ listing.show_url }}">{{ listing.name }}</a></span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Needs Help With:</strong>
    <span style="float: right;">{% assign services = reservation.properties.service_category | split: ',' %}{{ services | join: ', ' }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Technical Issue Description</strong>
    <span style="float: right;">{{ reservation.properties.technical_description }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Suggested Date &amp; Time</strong>
    <span style="float: right;">{{ reservation.starts_at | localize: 'long' }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Where</strong>
    <span style="float: right;">{{ reservation.address.address }} [ <a href="http://maps.apple.com/?q={{reservation..address.address}}" target='_blank'>{{ 'dashboard.user_reservations.show_on_map' | translate }}</a> ]</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Price</strong>
    <span style="float: right; clear: right;">{{ reservation.formatted_unit_price }} / hour</span>
  </div>

</div>

<p>You can manage your missions here:</p>

<a class="btn" href="{{ platform_context.host | append:user.bookings_dashboard_url_with_tracking_and_token | append:signature_for_tracking  }}">My Missions</a>

<p>We're always happy to help! If you have any questions about your booking, please send an email to <a href="{{ platform_context.support_email }}">{{ platform_context.support_email }}</a> {{ platform_context.phone_number }}.</p>
                                  ))

    create_email('reservation_mailer/notify_guest_of_expiration', %(
<h2>Sorry, {{ user.first_name }}!</h2>

<p>The mission has expired because the <a href="{{ listing.show_url }}">{{platform_context.lessor}}</a> has not confirmed it within the required 24 hours.</p>

<p>No worries! You can always find other Ninjas in your area.</p>

<a class="btn" href="{{ platform_context.host | append:listing.search_url_with_tracking | append:signature_for_tracking  }}">Search More Ninja</a>

<p>We're always happy to help! Just send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>

          ))

    create_email('reservation_mailer/notify_guest_with_confirmation', %(
<h2>Almost there, {{ user.first_name }}!</h2>

<p class="first-paragraph">
The mission for <a href="{{ listing.listing_url }}">{{ listing.name }}</a> is waiting for confirmation from the {{ platform_context.lessor }}! We'll get back to you as soon as the {{ platform_context.lessor }} confirms the mission. {{ platform_context.lessors | capitalize }} have 24 hours to confirm, but most reply sooner.
</p>

<a class="btn" href="{{ platform_context.host | append:user.bookings_dashboard_url_with_tracking_and_token | append:signature_for_tracking }}">View Your Mission</a>

<p>In the meantime, we're happy to help! If you have any questions about your mission, please send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>  {{ platform_context.phone_number }}.</p>

                                  ))

    create_email('reservation_mailer/notify_host_of_cancellation_by_guest', %(

<h2>Change of plans, {{ user.first_name }}!</h2>

<p>The mission at {{ reservation.address.address }} has been cancelled by the {{ platform_context.lessee }}.</p>

<p>No worries! We are working hard to send more {{ platform_context.lessees }} your way.</p>

<p>We're always happy to help! Just send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>
                                  ))

    create_email('reservation_mailer/notify_host_of_cancellation_by_host', %(

<h2>What happened, {{ user.first_name }}?</h2>

<p>We noticed that you just cancelled {{ reservation.owner.first_name }}'s mission.</p>

<p>Plans change, we get it. Just let us know the reasons by clicking the big button below. That will help us to provide a better service in the future for you and your {{ platform_context.lessees }}.</p>

<a class="btn" href="mailto:{{ platform_context.support_email }}">Send Feedback</a>

<p>If you prefer, you can talk with us directly; just send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>

<p>We'll be glad to help you!</p>
                                  ))

    create_email('reservation_mailer/notify_guest_of_cancellation_by_guest', %(

<h2>What happened, {{ user.first_name }}?</h2>

<p>We noticed that you just cancelled your mission.</p>

<p>Plans change, we get it. Just let us know the reasons by clicking the big button below. That will help us to provide a better service in the future for you and your {{ platform_context.lessees }}.</p>

<a class="btn" href="mailto:{{ platform_context.support_email }}">Send Feedback</a>

<p>If you prefer, you can talk with us directly; just send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>

<p>We'll be glad to help you!</p>
                                  ))

    create_email('reservation_mailer/notify_host_of_confirmation', %(

<h2>Thanks, {{ user.first_name }}!</h2>

<p class="first-paragraph">
Thanks for confirming {{ reservation.owner.first_name }}'s mission! You can <a href="{{ platform_context.host | append:listing.manage_guests_dashboard_url }}">manage {{ platform_context.lessee }} missions via the Dashboard</a>.
</p>

<p>If you need help, please contact us at <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>
                                  ))

    create_email('reservation_mailer/notify_host_of_rejection', %(

<h2>Can we help, {{ user.first_name }}?</h2>

<p>We noticed that you declined {{ reservation.owner.first_name }}'s mission.</p>

<p>We'd love to know the reasons so we can provide a better service in the future for you and your potential {{ platform_context.lessees }}.</p>

<p>Just reply to this email - we value your feedback!</p>
                                  ))

    create_email('reservation_mailer/notify_host_with_confirmation', %(

<h2>Good news, {{ user.first_name }}!</h2>

<p>
  You have got new mission!
</p>

<div class="booking-details">

  <div class="row">
    <strong style='display: inline-block;'>Who</strong>
    <span style="float: right;"><a href="{{ platform_context.host | append:reservation.owner.user_profile_url }}">{{ reservation.owner.first_name }}</a></span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Needs Help With:</strong>
    <span style="float: right;">{% assign services = reservation.properties.service_category | split: ',' %}{{ services | join: ', ' }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Technical Issue Description</strong>
    <span style="float: right;">{{ reservation.properties.technical_description }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Suggested Date &amp; Time</strong>
    <span style="float: right;">{{ reservation.starts_at | localize: 'long' }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Where</strong>
    <span style="float: right;">{{ reservation.address.address }} [ <a href="http://maps.apple.com/?q={{reservation..address.address}}" target='_blank'>{{ 'dashboard.user_reservations.show_on_map' | translate }}</a> ]</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Price</strong>
    <span style="float: right; clear: right;">{{ reservation.formatted_unit_price }} / hour</span>
  </div>

</div>

<p>Exciting, right? Please, confirm the mission and let's get the {{ platform_context.lessee }} set up!</p>

<a class="btn" href="{{ platform_context.host | append:reservation.reservation_confirm_url_with_tracking | append:signature_for_tracking }}">Confirm Mission</a>

<p>Not ready for {{ platform_context.lessees }}? You can manage your clients <a href="{{ platform_context.host | append:listing.manage_guests_dashboard_url }}">here</a>.</p>

<p>If you need help, send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>
                                  ))

    create_email('reservation_mailer/notify_host_without_confirmation', %(
<h2>Good news, {{ user.first_name }}!</h2>

<p>
  You have got new mission!
</p>

<div class="booking-details">

  <div class="row">
    <strong style='display: inline-block;'>Who</strong>
    <span style="float: right;"><a href="{{ platform_context.host | append:reservation.owner.user_profile_url }}">{{ reservation.owner.first_name }}</a></span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Needs Help With:</strong>
    <span style="float: right;">{% assign services = reservation.properties.service_category | split: ',' %}{{ services | join: ', ' }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Technical Issue Description</strong>
    <span style="float: right;">{{ reservation.properties.technical_description }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Suggested Date &amp; Time</strong>
    <span style="float: right;">{{ reservation.starts_at | localize: 'long' }}</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Where</strong>
    <span style="float: right;">{{ reservation.address.address }} [ <a href="http://maps.apple.com/?q={{reservation..address.address}}" target='_blank'>{{ 'dashboard.user_reservations.show_on_map' | translate }}</a> ]</span>
  </div>

  <div class="row">
    <strong style='display: inline-block;'>Price</strong>
    <span style="float: right; clear: right;">{{ reservation.formatted_unit_price }} / hour</span>
  </div>

</div>

<p>Exciting, right? You can manage this booking from the Dashboard.</p>

<a class="btn" href="{{ platform_context.host | append:listing.manage_guests_dashboard_url_with_tracking | append:signature_for_tracking }}">Manage {{ platform_context.lessees | capitalize }}</a>

<p>If you need help, send an email to <a href="mailto:{{ platform_context.support_email }}">{{ platform_context.support_email }}</a>.</p>

                              ))

    create_sms('reservation_sms_notifier/notify_guest_with_state_change', %(
Your mission for {{ reservation.transactable.name | truncate: 90 }} was {{ reservation.state_to_string }}. View mission: {{ platform_context.host | append:reservation.bookings_dashboard_url | shorten_url}}
                                  ))
    create_sms('reservation_sms_notifier/notify_host_with_confirmation', %(
You have received a mission request on {{ platform_context.name | truncate: 50 }}. Please confirm or decline from your dashboard: {{ platform_context.host | append:reservation.manage_guests_dashboard_url | shorten_url}}
                                  ))

    create_sms('user_message_sms_notifier/notify_user_about_new_message', %(
[{{ @platform_context.name }}] New message from {{ user_message.author_first_name }}: "{{ user_message.body }}" {{ platform_context.host | append:user_message.show_path_with_token | shorten_url}}
                                  ))

    WorkflowAlert.where(template_path: 'company_sms_notifier/notify_host_of_no_payout_option').destroy_all

    create_email('reservation_mailer/notify_guest_of_penalty_charge_succeeded', %(
<h2>Hello, {{ user.first_name }}?</h2>

<p>We have noticed you have just canceled your mission.</p>

<p>The cancelation policy you agreed to is that you can cancel without any fees up to {{ reservation.cancellation_policy_hours_for_cancellation }} hours before the mission starts. Unfortunately, you have canceled it after this period, therefore we have charged you for {{ reservation.cancellation_policy_penalty_hours }} hours.</p>

<p>The total cancelation fee is {{ reservation.formatted_total_amount }}</p>

<p>We're always happy to help! If you have any questions about your booking or cancelation, please send an email to <a href="{{ platform_context.support_email }}">{{ platform_context.support_email }}</a> or contact us at {{ platform_context.phone_number }}.</p>
                                  ))

    create_email('reservation_mailer/notify_guest_of_penalty_charge_failed', %(
<h2>Hello, {{ user.first_name }}?</h2>

<p>We have noticed you have just canceled your mission.</p>

<p>The cancelation policy you agreed to is that you can cancel without any fees up to {{ reservation.cancellation_policy_hours_for_cancellation }} hours before the mission starts. Unfortunately, you have canceled it after this period, therefore we have to charge you for {{ reservation.cancellation_policy_penalty_hours }} hours.</p>

<p>The total cancelation fee is {{ reservation.formatted_total_amount }}. Since we're not able to capture payment using the payment information you provided during mission creation, please update your payment information in the dashboard. Until you update your payment information, you will no longer be able to create future missions.</p>

<p><a class="btn" href="{{ reservation.guest_show_url }}">Update payment information</a></p>

<p>We're always happy to help! If you have any questions about your booking, please send an email to <a href="{{ platform_context.support_email }}">{{ platform_context.support_email }}</a> or contact us at {{ platform_context.phone_number }}.</p>
                                  ))
  end

  def create_email(path, body)
    iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'html', partial: false).first_or_initialize
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.body = body
    iv.save!

    iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
    iv.body = ActionView::Base.full_sanitizer.sanitize(body)
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.save!
  end

  def create_sms(path, body)
    iv = InstanceView.where(instance_id: @instance.id, view_type: 'sms', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.body = body
    iv.save!
  end

  def create_translation!(key, value)
    @instance.translations.where(
      locale: 'en',
      key: key
    ).first_or_initialize.update!(value: value)
  end

  def convert_hash_to_dot_notation(hash, path = '')
    hash.each_with_object({}) do |(k, v), ret|
      key = path + k

      if v.is_a? Hash
        ret.merge! convert_hash_to_dot_notation(v, key + '.')
      else
        ret[key] = v
      end
    end
  end

  def create_custom_validators!
    cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.seller.first).first_or_initialize
    cv.required = '1'
    cv.save!

    cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.buyer.first).first_or_initialize
    cv.required = '1'
    cv.save!
  end
end
