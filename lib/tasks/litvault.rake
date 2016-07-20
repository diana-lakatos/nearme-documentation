namespace :litvault do

  desc 'Setup LitVault'
  task setup: :environment do

    @instance = Instance.find(198)
    @instance.update_attributes(
      tt_select_type: 'dropdown',
      split_registration: true
    )
    @instance.set_context!

    create_transactable_types!
    set_theme_options
    create_content_holders
    create_views
    create_translations
    expire_cache
  end

  def create_transactable_types!
    transactable_type = @instance.transactable_types.where(name: 'CaseType1').first_or_initialize
    transactable_type.attributes = {
      name: 'CaseType1',
      slug: 'case_type1',
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
      bookable_noun: 'CaseType1',
      enable_photo_required: true,
      min_hourly_price_cents: 50_00,
      max_hourly_price_cents: 150_00,
      lessor: 'Lawyer',
      lessee: 'Client',
      enable_reviews: true
    }
    transactable_type.save!

    transactable_type = @instance.transactable_types.where(name: 'CaseType2').first_or_initialize
    transactable_type.attributes = {
      name: 'CaseType2',
      slug: 'case_type2',
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
      bookable_noun: 'CaseType2',
      enable_photo_required: true,
      min_hourly_price_cents: 50_00,
      max_hourly_price_cents: 150_00,
      lessor: 'Lawyer',
      lessee: 'Client',
      enable_reviews: true
    }
    transactable_type.save!
  end

  def set_theme_options
    theme = @instance.theme

    theme.color_green = '#4fc6e1'
    theme.call_to_action = 'Learn more'

    theme.phone_number = '1-555-555-55555'
    theme.contact_email = 'support@litvault.com'
    theme.support_email = 'support@litvault.com'

    theme.facebook_url = 'https://facebook.com'
    theme.twitter_url = 'https://twitter.com'
    theme.gplus_url = 'https://plus.google.com'
    theme.instagram_url = 'https://www.instagram.com'
    theme.youtube_url = 'https://www.youtube.com'

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
      content: "<link rel='stylesheet' media='screen' href='https://s3-us-west-1.amazonaws.com/near-me-staging/instances/198/uploads/ckeditor/attachment_file/data/2699/litvault.css'>",
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
    create_theme_header!
    create_search_box_inputs!
    create_home_homepage_content!
    create_listing_show!
    create_theme_footer!
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
            <li><a href='#' class='nav-link'>Facebook</a></li>
            <li><a href='#' class='nav-link'>Twitter</a></li>
            <li><a href='#' class='nav-link'>Linkedin</a></li>
            <li><a href='#' class='nav-link'>Google+</a></li>
            <li><a href='#' class='nav-link'>Blog</a></li>
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
  The Easiest Way For Experienced Trial Lawyers To Get <span class='text-highlight'>Quality Contingent Fee Referrals</span>
</h2>

<form action="/search" class="home_search search-box {{ class_name }}" method="get">
  <div class="input-wrapper">

    <div class="row-fluid">
      {% for transactable_type in transactable_types %}
        <div class="transactable-type-search-box" data-transactable-type-id="{{ transactable_type.select_id }}" {% if forloop.first != true %} style=" display: none;" {% endif%}>
          {% include 'home/search/fulltext' %}
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

    <a href='#' class='learn-more'>LEARN MORE</a>

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
        <h3 class='text-lighter'>Sign up and find out how easy it is to list your first case.</h3>
        <a href='#' class='sign-up'>SIGN UP</a>
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
            <div class='image'><img src='/litvault/michealduncan.png' /></div>
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
    <img src='/litvault/litvault-logo-icon.png'>
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
      <li><a href='#' ref='nofollow' target='_blank'><span class='image icon-twitter'></span>Linkedin</a></li>
      {% if platform_context.gplus_url != blank %}<li><a href="{{ platform_context.gplus_url }}" rel="publisher nofollow" target="_blank"><span class="image icon-gplus"></span>Google+</a></li>{% endif %}
      {% if platform_context.instagram_url != blank %}<li><a href="{{ platform_context.instagram_url }}" ref="nofollow"  target="_blank"> <span class="image icon-instagram"></span>Instagram</a></li>{% endif %}
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
