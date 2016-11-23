# frozen_string_literal: true
require 'yaml'
require 'benchmark'
require 'utils/form_components_creator'

class MarketplaceBuilder
  MODE_REPLACE = 'replace'
  MODE_APPEND = 'append'

  def initialize(instance_id, theme_path, mode = MODE_APPEND)
    @instance = Instance.find(instance_id)
    @instance.set_context!

    puts "\nMarketplace Builder loaded for \e[32m#{@instance.name}\e[0m"

    @mode = mode

    @theme_path = theme_path
    @last_run_time = 0
  end

  def run
    @last_run_time = Benchmark.realtime do
      create_custom_attributes!
      create_categories!
      create_or_update_form_components!
      create_pages!
      create_content_holders!
      create_mailers!
      create_smses!
      create_liquid_views!
      create_translations!
      expire_cache
    end

    puts "\n\e[32mDone in #{@last_run_time.round(2)}s\e[0m\n\n"
  end

  def create_custom_attributes!
    create_transactable_type_attributes!
    create_instance_profile_type_attributes!
    create_reservation_type_attributes!
  end

  def create_reservation_type_attributes!
    path = File.join(@theme_path, 'custom_attributes', 'reservation_types.yml')
    return unless File.file? path

    puts "\nCustom reservation type attributes:"

    custom_attributes = YAML.load_file(path)
    custom_attributes.keys.each do |rt_name|
      puts "\n\t#{rt_name}:"
      object = @instance.reservation_types.where(name: rt_name).first
      update_custom_attributes_for_object(object, custom_attributes[rt_name])
    end
  end

  def create_transactable_type_attributes!
    path = File.join(@theme_path, 'custom_attributes', 'transactable_types.yml')
    return unless File.file? path

    puts "\nCustom transactable type attributes:"

    custom_attributes = YAML.load_file(path)
    custom_attributes.keys.each do |tt_name|
      puts "\n\t#{tt_name}:"
      object = @instance.transactable_types.where(name: tt_name).first
      update_custom_attributes_for_object(object, custom_attributes[tt_name])
    end
  end

  def create_instance_profile_type_attributes!
    path = File.join(@theme_path, 'custom_attributes', 'instance_profile_types.yml')
    return unless File.file? path

    puts "\nCustom instance profile type attributes:"

    custom_attributes = YAML.load_file(path)
    custom_attributes.keys.each do |id|
      puts "\n\tInstanceProfileType ##{id}:"
      object = InstanceProfileType.find(id)
      update_custom_attributes_for_object(object, custom_attributes[id])
    end
  end

  def create_categories!
    path = File.join(@theme_path, 'categories', 'transactable_types.yml')
    return unless File.file? path

    puts "\nCreating categories:"

    categories = YAML.load_file(path)
    remove_unused_categories(categories)
    categories.keys.each do |tt_name|
      puts "\n\t#{tt_name}:"
      object = @instance.transactable_types.where(name: tt_name).first
      update_categories_for_object(object, categories[tt_name])
    end
  end

  def create_or_update_form_components!
    create_or_update_form_components_for_transactable_types!
    create_or_update_form_components_for_reservation_types!
    create_or_update_form_components_for_instance_profile_types!
  end

  def create_or_update_form_components_for_transactable_types!
    path = File.join(@theme_path, 'form_components', 'transactable_types.yml')
    return unless File.file? path

    puts "\nTransactable Types: Creating form components"
    transactable_types = YAML.load_file(path)

    transactable_types.keys.each do |tt_name|
      puts "\n\t#{tt_name}:"
      object = @instance.transactable_types.where(name: tt_name).first

      puts "\t  Cleanup..."
      object.form_components.destroy_all
      create_form_components_for_object(object, transactable_types[tt_name])
    end
  end

  def create_or_update_form_components_for_instance_profile_types!
    path = File.join(@theme_path, 'form_components', 'instance_profile_types.yml')
    return unless File.file? path

    puts "\nUpdating existing form components"

    instance_profile_types = YAML.load_file(path)
    instance_profile_types.keys.each do |id|
      fc = FormComponent.find(id)
      fc.update_attribute(:form_fields, instance_profile_types[id])
      puts "\t- #{fc.name}:"
      instance_profile_types[id].each do |object|
        puts "\t\t- #{object.keys.first}: #{object.values.first}"
      end
    end
  end

  def create_or_update_form_components_for_reservation_types!
    path = File.join(@theme_path, 'form_components', 'reservation_types.yml')
    return unless File.file? path

    puts "\nReservation Types: Creating form components"

    reservation_types = YAML.load_file(path)
    reservation_types.keys.each do |rt_name|
      puts "\n\t#{rt_name}:"
      object = @instance.reservation_types.where(name: rt_name).first

      puts "\t  Cleanup..."
      object.form_components.destroy_all
      create_form_components_for_object(object, reservation_types[rt_name])
    end
  end

  def create_pages!
    puts "\nCreating pages:"

    @instance.theme.pages.destroy_all if @mode == MODE_REPLACE

    templates = get_templates_from_dir(File.join(@theme_path, 'pages'))
    templates.each do |template|
      create_page(template.name, template.body)
      puts "\t- #{template.name}"
    end
  end

  def create_content_holders!
    puts "\nCreating content holders:"

    @instance.theme.content_holders.destroy_all if @mode == MODE_REPLACE

    templates = get_templates_from_dir(File.join(@theme_path, 'content_holders'), inject_pages: 'any_page',
                                                                                  position: 'head_bottom')

    templates.each do |template|
      create_content_holder(template.name, template.body, template.inject_pages, template.position)
      puts "\t- #{template.name}"
    end
  end

  def create_mailers!
    puts "\nCreating mailers:"
    templates = get_templates_from_dir(File.join(@theme_path, 'mailers'))
    templates.each do |template|
      create_email(template.liquid_path, template.body)
      puts "\t- #{template.liquid_path}"
    end
  end

  def create_smses!
    puts "\nCreating smses:"
    templates = get_templates_from_dir(File.join(@theme_path, 'sms'))
    templates.each do |template|
      create_email(template.liquid_path, template.body)
      puts "\t- #{template.liquid_path}"
    end
  end

  def create_liquid_views!
    puts "\nCreating liquid views:"

    @instance.instance_views.liquid_views.destroy_all if @mode == MODE_REPLACE

    templates = get_templates_from_dir(File.join(@theme_path, 'liquid_views'))

    templates.each do |template|
      create_liquid_view(template.liquid_path, template.body, template.partial)
      puts "\t- #{template.liquid_path}"
    end
  end

  # TODO: This should support multiple locales
  def create_translations!
    path = File.join(@theme_path, 'translations', 'en.yml')
    return unless File.file? path

    # puts "\nTranslating:"

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

    #     new_value.gsub!('Cases_count', 'listings_count')

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

    locales = YAML.load_file(path)
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

    CacheExpiration.send_expire_command 'RebuildInstanceView', instance_id: @instance.id
    CacheExpiration.send_expire_command 'RebuildTranslations', instance_id: @instance.id
    CacheExpiration.send_expire_command 'RebuildCustomAttributes', instance_id: @instance.id
    Rails.cache.clear
  end

  private

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

  def get_templates_from_dir(template_folder, defaults = {})
    template_files = Dir.glob("#{template_folder}/**/*").select { |path| File.file?(path) && /\.keep$/.match(path).nil? }
    template_files.map! do |filename|
      defaults[:partial] = !/^_/.match(File.basename(filename)).nil?
      load_file_with_yaml_front_matter(filename, template_folder, defaults)
    end
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
    inject_pages = [inject_pages] if inject_pages.is_a?(String)
    ch = @instance.theme.content_holders.where(
      name: name
    ).first_or_initialize

    ch.update!(content: body,
               inject_pages: inject_pages,
               position: position)
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
      path: path
    ).first_or_initialize
    iv.update!(transactable_types: TransactableType.all,
               body: body,
               format: 'html',
               handler: 'liquid',
               partial: partial,
               view_type: 'view',
               locales: Locale.all)
  end

  def load_file_with_yaml_front_matter(path, template_folder, config = {})
    body = File.read(path)
    regex = /\A---(.|\n)*?---\n/

    # search for YAML front matter
    yfm = body.match(regex)
    if yfm
      config = config.merge(YAML.load(yfm[0]))
      body.gsub!(regex, '')
    end
    config = config.merge(body: body)

    config['liquid_path'] ||= path.sub("#{template_folder}/", '').gsub(/\.[a-z]+$/, '').gsub(/\/_(?=[^\/]+$)/, '/') # first remove folder path, then file extension, then `_` partial symbol
    config['name'] ||= File.basename(path, '.*').sub(/^_/, '').humanize.titleize
    config['path'] ||= path

    OpenStruct.new(config)
    end

  def create_custom_attribute(object, name, hash)
    hash = hash.with_indifferent_access
    custom_attribute = object.custom_attributes.where(name: name).first_or_initialize
    custom_attribute.custom_validators.destroy_all

    custom_attribute.assign_attributes(hash)
    custom_attribute.save!
    custom_attribute.custom_validators.each(&:save!)
  end

  def remove_unused_categories(categories)
    used_categories = []
    categories.each do |_tt, cats|
      used_categories.concat(cats.keys)
    end
    used_categories.uniq!

    unused_categories = Category.where('name NOT IN (?) AND parent_id IS NULL', used_categories)
    unless unused_categories.empty?
      puts "\tRemoving unused categories:"
      unused_categories.each do |category|
        puts "\t  - #{category.name}"
        category.destroy!
      end
    end
  end

  def update_categories_for_object(tt, categories)
    puts "\t  Updating / creating categories:"
    categories.each do |name, hash|
      hash = default_category_properties.merge(hash.symbolize_keys)
      children = hash.delete(:children) || []
      category = Category.where(name: name).first_or_create!
      category.transactable_types = category.transactable_types.push(tt) unless category.transactable_types.include?(tt)
      category.instance_profile_types = category.instance_profile_types.push(InstanceProfileType.buyer.first) if hash.delete('assign_to_buyer_profile') && !category.instance_profile_types.include?(InstanceProfileType.buyer.first)
      category.save!

      puts "\t    - #{name}"

      create_category_tree(category, children, 1)
    end
  end

  def create_category_tree(category, children, level)
    children.each do |child|
      name = child.is_a? Hash ? child['name'] : child
      subcategory = category.children.where(name: name).first_or_create!(parent_id: category.id)
      puts "\t    #{'  ' * (level + 1)}- #{name}"
      create_category_tree(subcategory, child['children'], level + 1) if child['children']
    end
  end

  def update_custom_attributes_for_object(object, attributes)
    attributes ||= {}
    unused_attrs = if attributes.empty?
                     object.custom_attributes
                   else
                     object.custom_attributes.where('name NOT IN (?)', attributes.keys)
                   end

    unless unused_attrs.empty?
      puts "\t  Removing unused attributes:"
      unused_attrs.each do |ca|
        puts "\t    - #{ca.name}"
        ca.destroy
      end
    end

    unless attributes.empty?
      puts "\t  Updating / creating attributes:"
      attributes.each do |name, attrs|
        create_custom_attribute(object, name, default_attribute_properties.merge(attrs.symbolize_keys))
        puts "\t    - #{name}"
      end
    end
  end

  def default_category_properties
    {
      mandatory: false,
      multiple_root_categories: false,
      search_options: 'include',
      children: []
    }
  end

  def default_attribute_properties
    {
      attribute_type: 'string',
      html_tag: 'input',
      public: true,
      searchable: false,
      required: false
    }
  end

  def create_form_components_for_object(object, component_types)
    component_types.each do |type, components|
      puts "\t  Creating #{type}..."
      creator = Utils::BaseComponentCreator.new(object)
      creator.instance_variable_set(:@form_type_class, "FormComponent::#{type}".safe_constantize)
      components.map!(&:symbolize_keys)
      creator.create_components!(components)
    end
  end
end
