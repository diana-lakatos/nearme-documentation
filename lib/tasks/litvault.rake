namespace :litvault do

  desc 'Setup LitVault'
  task setup: :environment do

    @instance = Instance.find(198)
    @instance.update_attributes(
      split_registration: true
    )
    @instance.set_context!

    create_views
    create_translations
    expire_cache
  end

  def expire_cache
    CacheExpiration.send_expire_command 'InstanceView', instance_id: 198
    CacheExpiration.send_expire_command 'Translation', instance_id: 198
    CacheExpiration.send_expire_command 'CustomAttribute', instance_id: 198
    Rails.cache.clear
  end

  def create_views
    create_listing_show!
  end

  def create_translations
    transformation_hash = {
      'reservation' => 'offer',
      'Reservation' => 'Offer',
      'booking' => 'offer',
      'Booking' => 'Offer',
      'host' => 'Referring Lawyer',
      'Host' => 'Referring Lawyer',
      'guest' => 'Handling Lawyer',
      'Guest' => 'Handling Lawyer',
      'this listing' => 'your Case',
      'that listing' => 'your Case',
      'This listing' => 'Your Case',
      'That listing' => 'Your Case',
      'listing' => 'Case'
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
    ).first_or_initialize.update!(value: 'Sign Up for LitVault')

    @instance.translations.where(
      locale: 'en',
      key: 'sign_up_form.seller_sign_up_to'
    ).first_or_initialize.update!(value: 'Create a Referring Lawyer Account')

    @instance.translations.where(
      locale: 'en',
      key: 'ui.header.list_your_thing'
    ).first_or_initialize.update!(value: 'Become a Referring Lawyer')

    @instance.translations.where(
      locale: 'en',
      key: 'registrations.accept_terms_of_service'
    ).first_or_initialize.update!(value: 'Yes, I understand and agree to <a href="/terms-of-use" target="_blank">Terms of Service</a> including the <a href="/user-agreement" target="_blank">User Agreement</a> and <a href="/privacy-policy" target="_blank">Privacy Policy</a>')

    @instance.translations.where(
      locale: 'en',
      key: 'onboarding_wizard.list_your'
    ).first_or_initialize.update!(value: 'Complete Your Case')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.user_reservations'
    ).first_or_initialize.update!(value: 'My Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.reviews'
    ).first_or_initialize.update!(value: 'Ratings')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.host_reservations'
    ).first_or_initialize.update!(value: 'My Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.edit'
    ).first_or_initialize.update!(value: 'Account')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.transactables'
    ).first_or_initialize.update!(value: 'My Cases')

    @instance.translations.where(
      locale: 'en',
      key: 'top_navbar.my_bookings'
    ).first_or_initialize.update!(value: 'My Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.user_reservations.reservation_placed_html'
    ).first_or_initialize.update!(value: 'Offer created: <span>%{date}</span>')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.analytics.bookings'
    ).first_or_initialize.update!(value: 'Offers')

    create_translation!('dashboard.user_reservations.title_count', "Offers (%{count})")

    create_translation!('general.generic_lessee_term', "client")



    create_translation!('dashboard.host_reservations.no_unconfirmed_reservations', "You have no unconfirmed offers.")
    create_translation!('dashboard.host_reservations.no_confirmed_reservations', "You have no confirmed offers.")
    create_translation!('dashboard.host_reservations.no_archived_reservations', "You have no archived offers.")
    create_translation!('dashboard.host_reservations.no_overdue_reservations', "You have no overdue offers.")
    create_translation!('dashboard.host_reservations.no_reservations_promote_reservations', "You currently have no offers.")

    create_translation!('dashboard.analytics.no_reservations_yet', "You currently do not have any offers.")

    create_translation!('simple_form.labels.transactable.confirm_reservations', "Manually confirm offers")

    create_translation!('dashboard.nav.user_reservations_count_html', "My Offers <span>%{count}</span>")

    create_translation!('dashboard.analytics.columns.bookings', 'Offers')
    create_translation!('dashboard.analytics.total.bookings', "%{total} offers")

    create_translation!('dashboard.host_reservations.pending_confirmation', "You must confirm this offer within <strong>%{time_to_expiry}</strong> or it will expire.")

    create_translation!('dashboard.transactables.title.listings', "My Cases")
    create_translation!('dashboard.manage_listings.tab', "My Cases")

    create_translation!('dashboard.user_reservations.upcoming', "Offers Open")
    create_translation!('dashboard.user_reservations.archived', "Offers Closed")

    create_translation!('dashboard.host_reservations.unconfirmed', "Offers Pending")
    create_translation!('dashboard.host_reservations.confirmed', "Offers Open")
    create_translation!('dashboard.host_reservations.archived', "Offers Closed")

    create_translation!('reservations.states.unconfirmed', "Pending")
    create_translation!('reservations.states.confirmed', "Open")
    create_translation!('reservations.states.archived', "Closed")
    create_translation!('reservations.states.cancelled_by_guest', "Cancelled by Handling Lawyer")
    create_translation!('reservations.states.cancelled_by_host', "Cancelled by Referring Lawyer")

    create_translation!('top_navbar.manage_bookable', "My Cases")
    create_translation!('top_navbar.bookings_received', "My Offers")
    create_translation!('reservations_review.heading', "Bid on Case")

    create_translation!('reservations_review.errors.whoops', "Whoops! We couldn't make that offer.")

    create_translation!('activemodel.errors.models.reservation_request.attributes.base.total_amount_changed', "Bid on Case")
    create_translation!('dashboard.items.new_listing_full', "Add new Case")

    create_translation!('reservations_review.disabled_buttons.request', "Bidding...")
    create_translation!('dashboard.transactables.view_html', "View Profile")

    create_translation!('buy_sell_market.products.labels.summary', "Overall Rating:")
    create_translation!('dashboard.items.delete_listing', "Delete Case")

    create_translation!('sign_up_form.link_to_buyer', "Become a member here")
    create_translation!('sign_up_form.link_to_seller', "Become a Referring Lawyer here")

    create_translation!('time.formats.short', "%l:%M %p")

    create_translation!('wish_lists.buttons.selected_state', "Favorite")
    create_translation!('wish_lists.buttons.unselected_state', "Favorite")

    create_translation!('flash_messages.space_wizard.space_listed', "Your Referring Lawyer profile has been submitted to the marketplace for approval. Please watch for a message indicating that your profile has been approved!")

    create_translation!('flash_messages.dashboard.locations.add_your_company', "Please complete your Case first.")
    create_translation!('flash_messages.dashboard.add_your_company', "Please complete your Case first.")
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
        ret.merge! convert_hash_to_dot_notation(v, key + ".")
      else
        ret[key] = v
      end
    end
  end

  def create_custom_validators!
    cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.seller.first).first_or_initialize
    cv.required = "1"
    cv.save!

    cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.buyer.first).first_or_initialize
    cv.required = "1"
    cv.save!
  end

  def create_listing_show!
    iv = InstanceView.where(
      instance_id: @instance.id,
      partial: true,
      path: 'listings/show'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
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
            <input type="submit" value="Bid on Case!">
          </form>
        </div>

        {% include 'shared/components/wish_list_button_injection.html', object: listing, link_to_classes: 'btn btn-white btn-large ask' %}

        <div class="missions-count">
          <span>Offers:</span> {{ listing.creator.completed_host_reservations_count }}
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
      locales: Locale.all
    })
  end

end
