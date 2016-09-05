require 'yaml'
require 'benchmark'

namespace :litvault do

  desc 'Setup LitVault'
  task setup: :environment do

    time = Benchmark.realtime do
      @instance = Instance.find(198)
      @instance.update_attributes(
        tt_select_type: 'radio',
        split_registration: true,
        enable_reply_button_on_host_reservations: true,
        hidden_ui_controls: { 'main_menu/cta': 1 },
        skip_company: true
      )
      @instance.set_context!
      InstanceProfileType.find(580).update_columns(onboarding: true, create_company_on_sign_up: true)

      setup = LitvaultSetup.new(@instance, File.join(Rails.root, 'lib', 'tasks', 'litvault'))
      setup.create_transactable_types!
      setup.create_custom_attributes!
      setup.create_categories!
      setup.create_or_update_form_components!

      setup.set_theme_options

      setup.create_content_holders
      setup.create_liquid_views
      setup.create_mailers
      setup.create_smses
      setup.create_pages
      setup.create_translations

      setup.expire_cache
    end

    puts "\nDone in #{time.round(2)}s\n\n"
  end

  class LitvaultSetup

    def initialize(instance, theme_path)
      @instance = instance
      @theme_path = theme_path
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
        single_transactable: false,
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
        single_transactable: false,
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
          name: 'states'
        }).first_or_initialize
        states.assign_attributes({
          label: 'States',
          attribute_type: 'array',
          html_tag: 'select',
          public: true,
          searchable: true,
          valid_values: %w(
            AL AK AZ AR CA CO CT DE FL GA HI ID IL IA KS KY
            LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC
            ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
          )
        })
        states.save!
      end
      law_firm = InstanceProfileType.find(580).custom_attributes.where(name: 'law_firm').first_or_initialize
      law_firm.assign_attributes({
        label: 'Law Firm',
        attribute_type: 'string',
        html_tag: 'input',
        public: true,
        searchable: false
      })
      law_firm.required = 1
      law_firm.save!

      law_firm = InstanceProfileType.find(579).custom_attributes.where(name: 'law_firm').first_or_initialize
      law_firm.assign_attributes({
        label: 'Law Firm',
        attribute_type: 'string',
        html_tag: 'input',
        public: true,
        searchable: false
      })
      law_firm.required = 1
      law_firm.save!
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
      FormComponent.find(5404).update_attribute(:form_fields, [ { "user" => "name" }, { "user" => "email" }, { "user" => "password" }, { "buyer" => "law_firm" } ])
      FormComponent.find(5402).update_attribute(:form_fields, [ { "user" => "name" }, { "user" => "email" }, { "user" => "password" }, { "buyer" => "law_firm" } ])
    end

    def set_theme_options
      @theme = @instance.theme
      @theme.color_green = '#4fc6e1'
      @theme.color_blue = '#4fc6e1'
      @theme.call_to_action = 'Learn more'
      @theme.phone_number = '1-555-555-55555'
      @theme.contact_email = 'support@litvault.com'
      @theme.support_email = 'support@litvault.com'
      @theme.facebook_url = 'https://facebook.com'
      @theme.twitter_url = 'https://twitter.com'
      @theme.gplus_url = 'https://plus.google.com'
      @theme.instagram_url = 'https://www.instagram.com'
      @theme.youtube_url = 'https://www.youtube.com'
      @theme.blog_url = 'http://blog.com'
      @theme.linkedin_url = 'https://www.linkedin.com'
      @theme.updated_at = Time.now
      @theme.save!
    end

    def create_custom_validators!
      cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.seller.first).first_or_initialize
      cv.required = "1"
      cv.save!

      cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.buyer.first).first_or_initialize
      cv.required = "1"
      cv.save!
    end

    def create_pages
      puts "\nCreating pages:"
      templates = get_templates_from_dir(File.join(@theme_path, 'pages'))
      templates.each do |template|
        create_page(template.name, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_content_holders
      puts "\nCreating content holders:"

      templates = get_templates_from_dir(File.join(@theme_path, 'content_holders'), {
        inject_pages: 'any_page',
        position: 'head_bottom'
      })

      templates.each do |template|
        create_content_holder(template.name, template.body, template.inject_pages, template.position)
        puts "\t- #{template.name}"
      end
    end

    def create_mailers
      puts "\nCreating mailers:"
      templates = get_templates_from_dir(File.join(@theme_path, 'mailers'))
      templates.each do |template|
        create_email(template.liquid_path, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_smses
      puts "\nCreating smses:"
      templates = get_templates_from_dir(File.join(@theme_path, 'sms'))
      templates.each do |template|
        create_email(template.liquid_path, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_liquid_views
      puts "\nCreating liquid views:"

      templates = get_templates_from_dir(File.join(@theme_path, 'liquid_views'), {
        partial: true
      })

      templates.each do |template|
        create_liquid_view(template.liquid_path, template.body, template.partial)
        puts "\t- #{template.name}"
      end
    end

    # TODO: This should support multiple locales
    def create_translations
      puts "\nTranslating:"

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
            print '.'
            $stdout.flush
          end
        end
      end

      locales = YAML.load_file(File.join(@theme_path, 'translations', 'en.yml'))
      locales_hash = convert_hash_to_dot_notation(locales['en'])

      locales_hash.each_pair do |key, value|
        create_translation(key, value, 'en')
        print '.'
        $stdout.flush
      end

      puts "\n"
    end


    def expire_cache
      puts "\nClearing cache..."
      CacheExpiration.send_expire_command 'InstanceView', instance_id: @instance.id
      CacheExpiration.send_expire_command 'Translation', instance_id: @instance.id
      CacheExpiration.send_expire_command 'CustomAttribute', instance_id: @instance.id
      Rails.cache.clear
    end

    private

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

      def get_templates_from_dir(template_folder, defaults = {})
        template_files = Dir.entries(template_folder).select{ |e| File.file?(File.join(template_folder, e)) && e != '.keep' }
        template_files.map! { |filename| load_file_with_yaml_front_matter(File.join(template_folder, filename), defaults) }
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

      def create_page(path, body)
        slug = path.parameterize
        page = @instance.theme.pages.where(slug: slug).first_or_initialize
        page.path = path
        page.content = body
        page.save
      end

      def create_content_holder(name, body, inject_pages, position)
        inject_pages = [inject_pages] if inject_pages.kind_of?(String)
        ch = @instance.theme.content_holders.where(
          name: name
        ).first_or_initialize

        ch.update!({
          content: body,
          inject_pages: inject_pages,
          position: position
        })
      end

      def create_translation(key, value, locale)
        @instance.translations.where(
          locale: locale,
          key: key
        ).first_or_initialize.update!(value: value)
      end

      def create_liquid_view(path, body, partial)
        iv = InstanceView.where(
          instance_id: @instance.id,
          path: path,
        ).first_or_initialize
        iv.update!({
          transactable_types: TransactableType.all,
          body: body,
          format: 'html',
          handler: 'liquid',
          partial: partial,
          view_type: 'view',
          locales: Locale.all
        })
      end

      def load_file_with_yaml_front_matter(path, config = {})
        body = File.read(path)
        regex = /\A---(.|\n)*?---\n/

        # search for YAML front matter
        yfm = body.match(regex)
        if yfm
          config = config.merge(YAML.load(yfm[0]))
          body.gsub!(regex, '')
        end
        config = config.merge({ body: body })

        config["liquid_path"] ||= File.basename(path, '.*').gsub('--','/')
        config["name"] ||= File.basename(path, '.*').gsub('--','/').humanize.titleize
        config["path"] ||= path

        OpenStruct.new(config)
      end

      def create_custom_attribute(object, hash)
          hash = hash.with_indifferent_access
          attr = object.custom_attributes.where({
            name: hash.delete(:name)
          }).first_or_initialize
          attr.assign_attributes(hash)
          attr.set_validation_rules!
      end
  end
end
