require 'yaml'
require 'benchmark'

namespace :volte do

  desc 'Setup Volte'
  task setup: :environment do

    time = Benchmark.realtime do

      @instance = Instance.find(194)
      # @instance.update_attributes(
      #   split_registration: true,
      #   enable_reply_button_on_host_reservations: true,
      #   hidden_ui_controls: {
      #     'main_menu/cta': 1,
      #     'dashboard/offers': 1,
      #     'dashboard/user_bids': 1,
      #     'dashboard/host_reservations': 1,
      #     'main_menu/my_bookings': 1
      #   },
      #   skip_company: true,
      #   click_to_call: true,
      #   wish_lists_enabled: true,
      #   default_currency: 'USD',
      #   default_country: 'United States',
      #   force_accepting_tos: true,
      #   user_blogs_enabled: true,
      #   force_fill_in_wizard_form: true,
        # test_twilio_consumer_key: 'ACc6efd025edf0bccc089965cdb7a63ed7',
        # test_twilio_consumer_secret: '0bcda4577848ec9708905296efcf6aa3',
      #   test_twilio_from_number: '+1 703-898-8300',
      #   test_twilio_consumer_key: 'AC107ea702c0d8255b0afc2baff62c345c',
      #   test_twilio_consumer_secret: 'df396dbe315d3e3d233ac76e49a1fabd',
      #   twilio_consumer_key: 'AC107ea702c0d8255b0afc2baff62c345c',
      #   twilio_consumer_secret: 'df396dbe315d3e3d233ac76e49a1fabd',
      #   twilio_from_number: '+1 703-898-8300'
        #TODO reenable for production
        # linkedin_consumer_key: '78uvu99t7fxfcz',
        # linkedin_consumer_secret: 'NGaQfcPmglHuaLOX'
      # )
      # @instance.create_documents_upload(
      #   enabled: true,
      #   requirement: 'mandatory'
      # )
      @instance.save
      @instance.set_context!

      # @default_profile_type = InstanceProfileType.find(569)
      # @instance_profile_type = InstanceProfileType.find(571)
      # @instance_profile_type.update_columns(
      #   onboarding: true,
      #   create_company_on_sign_up: true,
      #   show_categories: true,
      #   category_search_type: 'AND',
      #   searchable: true,
      #   search_only_enabled_profiles: true
      # )

      setup = VolteSetup.new(@instance, File.join(Rails.root, 'lib', 'tasks', 'volte'))
      setup.create_transactable_types!
      setup.create_custom_attributes!
      setup.create_custom_model!
      setup.create_categories!
      setup.create_or_update_form_components!

      setup.set_theme_options
      setup.create_content_holders
      setup.create_liquid_views
      setup.create_mailers
      setup.create_smses
      setup.create_pages
      setup.create_translations

      setup.create_workflow_alerts
      setup.expire_cache
    end

    puts "\nDone in #{time.round(2)}s\n\n"
  end

  class VolteSetup

    def initialize(instance, theme_path)
      @instance = instance
      @theme_path = theme_path
    end

    def create_custom_model!
    end

    def create_transactable_types!
    end


    def create_custom_attributes!
    end


    def create_categories!
    end

    def create_or_update_form_components!
    end

    def create_workflow_alerts
    end

    def set_theme_options
      theme = @instance.theme

      theme.color_green = '#4fc6e1'
      theme.color_blue = '#05caf9'
      theme.color_red = '#e83d33'
      theme.color_orange = '#ff8d00'
      theme.color_gray = '#333333'
      theme.color_black = '#171717'
      theme.color_white = '#ffffff'
      theme.call_to_action = 'Learn more'

      theme.contact_email = 'support@thevolte.com'

      theme.facebook_url = 'https://facebook.com'
      theme.twitter_url = 'https://twitter.com'
      theme.gplus_url = 'https://plus.google.com'
      theme.instagram_url = 'https://www.instagram.com'
      theme.youtube_url = 'https://www.youtube.com'
      theme.blog_url = '/blog'
      theme.linkedin_url = 'https://www.linkedin.com'

    #   theme.remote_favicon_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2760/favicon.png'
    #   theme.remote_icon_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2761/apple-touch-icon-60_2x.png'

      theme.updated_at = Time.now
      theme.save!
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

      # transformation_hash = {
      #   'reservation' => 'offer',
      #   'Reservation' => 'Offer',
      #   'booking' => 'offer',
      #   'Booking' => 'Offer',
      #   'host' => 'Referring Lawyer',
      #   'Host' => 'Referring Lawyer',
      #   'guest' => 'Handling Lawyer',
      #   'Guest' => 'Handling Lawyer',
      #   'this listing' => 'your Case',
      #   'that listing' => 'your Case',
      #   'This listing' => 'Your Case',
      #   'That listing' => 'Your Case',
      #   'listing' => 'Case'
      # }

      # (Dir.glob(Rails.root.join('config', 'locales', '*.en.yml')) + Dir.glob(Rails.root.join('config', 'locales', 'en.yml'))).each do |yml_filename|
      #   en_locales = YAML.load_file(yml_filename)
      #   en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

      #   en_locales_hash.each_pair do |key, value|
      #     next if value.blank?
      #     new_value = value
      #     transformation_hash.keys.each do |word|
      #       new_value = new_value.gsub(word, transformation_hash[word])
      #     end
      #     if value != new_value
      #       t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: @instance.id)
      #       t.value = new_value
      #       t.skip_expire_cache = true
      #       t.save!
      #       print '.'
      #       $stdout.flush
      #     end
      #   end
      # end

      locales = YAML.load_file(File.join(@theme_path, 'translations', 'en.yml'))

      if (locales['en'] != nil)
        locales_hash = convert_hash_to_dot_notation(locales['en'])

        locales_hash.each_pair do |key, value|
          create_translation(key, value, 'en')
          print '.'
          $stdout.flush
        end
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
        template_files = Dir.entries(template_folder).select{ |e| File.file? File.join(template_folder, e) }
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
