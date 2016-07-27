namespace :litvault do

  desc 'Setup LitVault'
  task setup: :environment do

    @instance = Instance.find(198)
    @instance.update_attributes(
      tt_select_type: 'radio',
      split_registration: true,
      hidden_ui_controls: { 'main_menu/cta': 1 }
    )
    @instance.set_context!

    create_transactable_types!
    create_custom_attributes!
    create_categories!
    create_or_update_form_components!
    set_theme_options
    create_content_holders
    create_views
    create_translations
    expire_cache
  end

  def create_transactable_types!
    transactable_type = @instance.transactable_types.where(name: 'Individual Case').first_or_initialize
    transactable_type.attributes = {
      name: 'Individual Case',
      slug: 'individual-case',
      action_free_booking: false,
      action_daily_booking: false,
      action_weekly_booking: false,
      action_monthly_booking: false,
      action_regular_booking: true,
      show_path_format: '/:transactable_type_id/:id',
      cancellation_policy_enabled: "1",
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
      bookable_noun: 'Individual Case',
      enable_photo_required: true,
      min_hourly_price_cents: 50_00,
      max_hourly_price_cents: 150_00,
      lessor: 'Lawyer',
      lessee: 'Client',
      enable_reviews: true
    }
    transactable_type.save!

    transactable_type = @instance.transactable_types.where(name: 'Group Case').first_or_initialize
    transactable_type.attributes = {
      name: 'Group Case',
      slug: 'group-case',
      action_free_booking: false,
      action_daily_booking: false,
      action_weekly_booking: false,
      action_monthly_booking: false,
      action_regular_booking: true,
      show_path_format: '/:transactable_type_id/:id',
      cancellation_policy_enabled: "1",
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
      bookable_noun: 'Group Case',
      enable_photo_required: true,
      min_hourly_price_cents: 50_00,
      max_hourly_price_cents: 150_00,
      lessor: 'Lawyer',
      lessee: 'Client',
      enable_reviews: true
    }
    transactable_type.save!
  end

  def create_custom_attributes!
    @instance.transactable_types.each do |tt|
      states = tt.custom_attributes.where({
        name: 'states',
        label: 'States',
        attribute_type: 'array',
        html_tag: 'select',
        public: true,
        searchable: true
      }).first_or_create!
      states.valid_values = %w(
        AL AK AZ AR CA CO CT DE FL GA HI ID IL IA KS KY
        LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC
        ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
      )
      states.save!
    end
  end

  def create_categories!
    root_category = Category.where(name: 'States').first_or_create!
    root_category.transactable_types = TransactableType.all
    root_category.mandatory = true
    root_category.multiple_root_categories = true
    root_category.search_options = 'exclude'
    root_category.save!

    %w(AL AK AZ AR CA CO CT DE FL GA HI ID IL IA KS KY
       LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC
       ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY).each do |category|
      root_category.children.where(name: category).first_or_create!
    end
  end

  def create_or_update_form_components!

    @instance.transactable_types.each do |tt|

      unless tt.form_components.any?
        Utils::FormComponentsCreator.new(tt).create!
      end

      tt.form_components.find_by(name: 'Where is your Case located?')
        .try(:update_column, :name, "Where is your #{tt.bookable_noun} located?")

      component = tt.form_components.find_by(name: "Where is your #{tt.bookable_noun} located?")
      component.form_fields = [
        {'location'     => 'name'},
        {'location'     => 'description'},
        {'location'     => 'address'},
        {'transactable' => 'states'},
        {'location'     => 'location_type'},
        {'location'     => 'phone'}
      ]

      component.save!
    end
  end

  def set_theme_options
    theme = @instance.theme

    theme.color_green = '#4fc6e1'
    theme.color_blue = '#4fc6e1'
    theme.call_to_action = 'Learn more'

    theme.phone_number = '1-555-555-55555'
    theme.contact_email = 'support@litvault.com'
    theme.support_email = 'support@litvault.com'

    theme.facebook_url = 'https://facebook.com'
    theme.twitter_url = 'https://twitter.com'
    theme.gplus_url = 'https://plus.google.com'
    theme.instagram_url = 'https://www.instagram.com'
    theme.youtube_url = 'https://www.youtube.com'
    theme.blog_url = 'http://blog.com'
    theme.linkedin_url = 'https://www.linkedin.com'

    ['About', 'About', 'How it Works', 'FAQ', 'Terms of Use', 'Privacy Policy'].each do |name|
      slug = name.parameterize
      page = theme.pages.where(slug: slug).first_or_initialize
      page.path = name
      page.content = %Q{}
      page.save
    end

    theme.updated_at = Time.now
    theme.save!
  end

  def create_content_holders
    ch = @instance.theme.content_holders.where(
      name: 'LitVault CSS'
    ).first_or_initialize

    ch.update!({
      content: "<link rel='stylesheet' media='screen' href='https://raw.githubusercontent.com/mdyd-dev/marketplaces/master/litvault/css/litvault.css'>",
      inject_pages: ['any_page'],
      position: 'head_bottom'
    })
  end

  def expire_cache
    CacheExpiration.send_expire_command 'InstanceView', instance_id: 198
    CacheExpiration.send_expire_command 'Translation', instance_id: 198
    CacheExpiration.send_expire_command 'CustomAttribute', instance_id: 198
    Rails.cache.clear
  end

  def create_views
    create_home_index!
    create_theme_header!
    create_search_box_inputs!
    create_home_search_fulltext!
    create_home_search_custom_attributes!
    create_home_homepage_content!
    create_listing_show!
    create_theme_footer!
    create_my_cases!
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

    @instance.translations.where(
      locale: 'en',
      key: 'homepage.search_field_placeholder.full_text'
    ).first_or_initialize.update!(value: 'General search...')

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

    create_translation!('flash_messages.space_wizard.space_listed', "Your Case has been submitted to the marketplace!")

    create_translation!('flash_messages.dashboard.locations.add_your_company', "Please complete your Case first.")
    create_translation!('flash_messages.dashboard.add_your_company', "Please complete your Case first.")

    create_translation!('transactable_types.individual_case.labels.search', 'Individual Cases')
    create_translation!('transactable_types.individual_case.labels.by_state', 'By State')
    create_translation!('transactable_types.individual_case.labels.all_states', 'All States')

    create_translation!('transactable_types.group_case.labels.search', 'Group Cases (Mass Torts)')
    create_translation!('transactable_types.group_case.labels.by_state.', 'By State')
    create_translation!('transactable_types.group_case.labels.all_states.', 'All States')
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

  def create_home_index!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/index'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% content_for 'hero' %}
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
      <span class="icon-arrow-down"></span>
    </a>
  </div>
{% endcontent_for %}

{% include 'home/homepage_content.html' %}
      },
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_theme_header!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'layouts/theme_header',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<div class='navbar navbar-inverse navbar-fixed-top'>
  <div class='navbar-inner nav-links'>
    <div class='container-fluid'>
        <a href='{{ platform_context.root_path }}' id="logo">{{ platform_context.name }}</a>

        <div class='header-social-links'>
          <ul class='nav main-menu'>
            {% if platform_context.facebook_url != blank %}<li><a href="{{ platform_context.facebook_url }}"  ref="nofollow" target="_blank"><span class="image icon-facebook"></span></a></li>{% endif %}
            {% if platform_context.twitter_url != blank %}<li><a href="{{ platform_context.twitter_url }}" ref="nofollow"  target="_blank"> <span class="image icon-twitter"></span></a></li>{% endif %}
            {% if platform_context.linkedin_url != blank %}<li><a href="{{ platform_context.linkedin_url }}" rel="publisher nofollow" target="_blank"><span class="image icon-linkedin"></span></a></li>{% endif %}
            {% if platform_context.gplus_url != blank %}<li><a href="{{ platform_context.gplus_url }}" rel="publisher nofollow" target="_blank"><span class="image icon-gplus"></span></a></li>{% endif %}
            {% if platform_context.blog_url != blank %}<li><a href="{{ platform_context.blog_url }}" ref="nofollow"  target="_blank"> <span class="image icon-feed"></span></a></li>{% endif %}
          </ul>
        </div>

        {% if no_header_links == false %}
          <div id='header_links' class='links-container pull-right'>
            <ul class="nav main-menu header-custom-links">
              <li>
                <a href='/' class='nav-link'>
                  <span class='text'>Home</span>
                </a>
              </li>

              <li>
                <a href='/?section=how-it-works' class='nav-link' scroll-to-section>
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
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_search_box_inputs!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/search_box_inputs',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<h2>
  <span class='first-line'>The Easiest Way For Experienced Trial</span>
  Lawyers To Get <span class='text-highlight'>Quality Contingent Fee Referrals</span></span>
</h2>

<form action="/search" class="home_search search-box {{ class_name }}" method="get">
  <div class="input-wrapper">

    <div class="row-fluid">
      {% for transactable_type in transactable_types %}
        <div class="transactable-type-search-box" data-transactable-type-id="{{ transactable_type.select_id }}" {% if forloop.first != true %} style=" display: none;" {% endif%}>
          {% include 'home/search/fulltext' %}
          {% include 'home/search/custom_attributes' transactable_type:transactable_type %}
        </div>
      {% endfor %}

      {% if transactable_types.size > 1 %}
        {% if platform_context.tt_select_type == 'dropdown' %}
          <div class="span2 transactable-select-wrapper">
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
            {% for transactable_type in transactable_types reversed %}
            <input type="radio" name="transactable_type_selector" value="{{ transactable_type.select_id }}" id="transactable-type-{{ transactable_type.id }}" {% if forloop.first == true %} checked {% endif %} data-transactable-type-picker >
            <label for="transactable-type-{{ transactable_type.id }}">
              {% capture i18n_key %}transactable_types.{{ transactable_type.name | parameterize:'_' }}.labels.search{% endcapture %}
              {{ i18n_key | translate }}
            </label>
            {% endfor %}
          </div>
        </div>
      </div>
    {% endif %}
  </div>
  <input type="hidden" name="transactable_type_class">
  <input type="submit"/>
</form>

<script type="text/javascript">
  $(document).ready(function() { $(document).trigger('init:homepageranges.nearme'); });
</script>
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_home_search_fulltext!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/search/fulltext'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<input class="query" name="query" placeholder="{{ transactable_type.fulltext_placeholder }}" type="text" >
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_home_search_custom_attributes!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/search/custom_attributes'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% for ca in transactable_type.custom_attributes %}
  {% capture i18n_by_state %}transactable_types.{{ transactable_type.name | parameterize:'_' }}.labels.by_state{% endcapture %}
  {% capture i18n_all_states %}transactable_types.{{ transactable_type.name | parameterize:'_' }}.labels.all_states{% endcapture %}

  <select class='no-icon select2 custom-attribute-select' name='lg_custom_attributes[{{ca.name}}][]' data-select2-placeholder='{{ i18n_by_state | translate }}'>
    <option></option>
    <option>{{ i18n_all_states | translate }}</option>
    {% for value in ca.valid_values %}
      <option value='{{ value }}'>{{ value }}</option>
    {% endfor %}
  </select>
{% endfor %}
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_home_homepage_content!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/homepage_content',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<section class='how-it-works'>
  <div class='container-fluid'>

    <header>
      <h2>How it Works</h2>
    </header>

    <div class='table-row'>
      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2683/icn-save-time-energy.png' /></div>
            <h3 class='text-highlight'>SAVE TIME + ENERGY</h3>
            <p>Our specialized marketplace connects <strong>Referring and Handling Lawyers</strong> to engage on a wide variety of contingent fee cases.</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2684/icn-quality-selection.png' /></div>
            <h3 class='text-highlight'>QUALITY CASE SELECTION</h3>
            <p>We provide a purpose-built platform that <strong>asks Referring Lawyers all the right questions</strong> so you don't have to.</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2685/icn-secure-compliant.png' /></div>
            <h3 class='text-highlight'>SECURE + COMPLIANT</h3>
            <p>Our cloud-based platform offers advanced security in a <strong>HIPAA compliant environment</strong> to protect private information.</p>
          </div>
        </div>
      </div>
    </div>

    <a href='/how-it-works' class='learn-more'>LEARN MORE</a>

  </div>
</section>

<section class='video'>
  <div class='container-fluid'>

    <div class="video-wrapper">
      <div class="video-constrainer">
        <h2>VIDEO</h2>
      </div>
    </div>

  </div>
</section>

<section class='benefits'>
  <div class='container-fluid'>

    <header>
      <h2>Benefits to <span class='text-highlight'>LitVault Members</span></h2>
      <h3>
        <span class='text-highlight'>Designed by lawyers for lawyers.</span>
        <span class='text-lighter'>Enjoy the time saving tools and process we have created.</span>
      </h3>
    </header>

    <div class='table-row'>
      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2686/icn-merit.png' /></div>
            <h3>Experience is Rewarded</h3>
            <p>This is not a place to develop a new practice area. Handling Law Firms can only compete for a case listing if they can show competence and experience in that practice area.</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2687/icn-case-alerts.png' /></div>
            <h3>Auto Case Notifications</h3>
            <p>Receive automatic notifications about new case listings in your practice area and your geography. Save your valuable time to work on cases instead of finding new cases.</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2688/icn-offer-engine.png' /></div>
            <h3>Simple Case Offer Engine</h3>
            <p>Negotiate and contract on case listings using our simple, intuitive case offer engine.  It provides consistency and saves you time and energy.</p>
          </div>
        </div>
      </div>
    </div>

    <div class='table-row'>
      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2689/icn-case-details.png' /></div>
            <h3>Rich Case Details</h3>
            <p>Our robust, curated case listing form already asks the Referring Lawyer the important questions about the facts of the case so you don't have to.</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2690/icn-security.png' /></div>
            <h3>Deal With Confidence</h3>
            <p>Reputations matter here. Members receive quality scores from other members on a variety of applicable criteria based on actual interactions on this site.</p>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2691/icn-hippa.png' /></div>
            <h3>Secure and HIPAA-Compliant</h3>
            <p>Our platform is built in a Amazon's HIPAA compliant AWS cloud platform for secure transmission of all types of case information.</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</section>

<section class='referring-lawyers'>
  <div class='container-fluid'>

    <div class='table-row'>
      <div class='sign-up table-cell'>
        <h2 class='text-highlight'>Referring Lawyers</h2>
        <h3 class='text-lighter'><span class='first-line'>Sign up and find out how</span> easy it is to list your first case.</h3>
        {% unless current_user %}
        <a href='#' data-href='/users/sign_up' data-modal='true' data-modal-class='sign-up-modal' data-modal-overlay-close='disabled' class='sign-up'>{{ 'top_navbar.sign_up' | translate }}</a>
        {% endunless %}
      </div>

      <div class='manage-on-mobile table-cell'>
        <p><span class='text-highlight'>Manage</span> all your cases, offers, and<br>communications from any mobile device.</p>
        <img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2692/iphone.png' />
      </div>
    </div>

  </div>
</section>

<section class='trusted-firms'>
  <div class='container-fluid'>

    <header>
      <h2>Trusted firms using <span class='text-highlight'>LitVault</span></h2>
      <h3><span class='text-lighter'>Designed by lawyers for lawyers. Enjoy the time saving tools and process we have created.</span></h3>
    </header>

    <img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2706/companies.png'>

  </div>
</section>

<section class='testimonials'>
  <div class='container-fluid'>

    <header>
      <h2><span class='text-highlight'>Testimonials</span></h2>
      <h3><span class='text-lighter'>Learn what other lawyers have to say about LitVault.</span></h3>
    </header>

    <div class='table-row'>
      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2693/johnsmith.png' /></div>
            <p>“LitVault takes a tedious process and converts into actionable simple steps.  I was able to get my case listed and live for review in a matter of minutes.”</p>
            <h3>John Smith</h3>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2694/robertmills.png' /></div>
            <p>“Posting cases and getting responses from interested and qualified lawyers is as easy as it gets.  I highly recommend LitVault to everyone!”</p>
            <h3>Robert Mills</h3>
          </div>
        </div>
      </div>

      <div class='teaser-wrapper table-cell'>
        <div class='teaser'>
          <div class='teaser-content'>
            <div class='image'><img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2695/michealduncan.png' /></div>
            <p>“This service saves my firm time and energy.  It has allowed me to connect and collaborate with many other trusted professionals.”</p>
            <h3>Micheal Duncan</h3>
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
      locales: Locale.all
    })
  end

  def create_listing_show!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'listings/show'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% if current_user == blank %}
  {% include 'listings/ask_for_sign_up.html' %}
{% else %}
  {% assign collaborator = current_user | find_collaborator: listing %}
  {% if collaborator.approved_by_owner? or current_user.id == listing.creator_id %}
    {% include 'listings/case_details.html' %}
  {% else %}
    {% include 'listings/ask_for_permission.html', collaborator: collaborator %}
  {% endif %}

{% endif %}

},
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_theme_footer!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'layouts/theme_footer',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<footer>

  <div class='description column'>
    <img src='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/picture/data/2700/litvault-logo-icon.png'>
    <p>LitVault is an online marketplace for the legal industry. We connect Referring and Handling Lawyers in order to collaborate on contingent fee plaintiffs' cases.</p>
  </div>

  <div class='general column'>
    <h4>General</h4>

    <ul>
      <li><a href='/'>Home</a></li>

      {% for page in platform_context.pages limit:3 %}
        <li><a href="{{ page.page_url }}" target="{{ page.open_in_target }}" rel="{{ page.link_rel }}">{{ page.title }}</a></li>
      {% endfor %}
    </ul>
  </div>

  <div class='more column'>
    <h4>More</h4>

    <ul>
      {% for page in platform_context.pages offset:3 %}
        <li><a href="{{ page.page_url }}" target="{{ page.open_in_target }}" rel="{{ page.link_rel }}">{{ page.title }}</a></li>
      {% endfor %}
    </ul>
  </div>

  <div class='connect column'>
    <h4>Connect</h4>

    <ul>
      {% if platform_context.facebook_url != blank %}<li><a href="{{ platform_context.facebook_url }}"  ref="nofollow" target="_blank"><span class="image icon-facebook"></span>Facebook</a></li>{% endif %}
      {% if platform_context.twitter_url != blank %}<li><a href="{{ platform_context.twitter_url }}" ref="nofollow"  target="_blank"> <span class="image icon-twitter"></span>Twitter</a></li>{% endif %}
      {% if platform_context.linkedin_url != blank %}<li><a href="{{ platform_context.linkedin_url }}" rel="publisher nofollow" target="_blank"><span class="image icon-linkedin"></span>Linkedin</a></li>{% endif %}
      {% if platform_context.gplus_url != blank %}<li><a href="{{ platform_context.gplus_url }}" rel="publisher nofollow" target="_blank"><span class="image icon-gplus"></span>Google+</a></li>{% endif %}
      {% if platform_context.blog_url != blank %}<li><a href="{{ platform_context.blog_url }}" ref="nofollow"  target="_blank"> <span class="image icon-feed"></span>Blog</a></li>{% endif %}
    </ul>
  </div>

  <div class='contact column'>
    <h4>Contact</h4>

    <h5>TELEPHONE</h5>
    <span>{{ platform_context.phone_number }}</span>

    <h5>SUPPORT</h5>
    <a href='mailto:{{ platform_context.support_email }}'>{{ platform_context.support_email }}</a>
  </div>

</footer>

<div class='copyright-wrapper'>
  <div class='copyright'>
    &copy; 2016 LitVault. All rights reserved.
  </div>
</div>
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_my_cases!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/user_reservations/reservation_details',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<div class="row">
  <div class="col-sm-6">Motorcycle | Broken Leg</div>
  <div class="col-sm-6" style="text-align: right">Days of Hospitalization: 45</div>
</div>
<div class="row">
  <div class="col-sm-6">Injury or Accident Date: 12/2/2015</div>
  <div class="col-sm-6" style="text-align: right">Death Case: N</div>
</div>
<div class="row">
  <div class="col-sm-6">Location of Injury or Accident: Missouri</div>
  <div class="col-sm-6" style="text-align: right"></div>
</div>

<p>{{ reservation.transactable.description | truncate: 500, "..." }}</p>
<hr/>
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  # def create_theme_footer!
  #   iv = InstanceView.where(
  #     instance_id: @instance.id,
  #     path: 'listings/show'
  #   ).first_or_initialize
  #   iv.update!({
  #     transactable_types: TransactableType.all,
  #     body: %Q{},
  #     format: 'html',
  #     handler: 'liquid',
  #     partial: true,
  #     view_type: 'view',
  #     locales: Locale.all
  #   })
  # end

end
