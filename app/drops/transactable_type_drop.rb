# frozen_string_literal: true
class TransactableTypeDrop < BaseDrop
  include CategoriesHelper

  # @!method id
  #   @return [Integer] numeric identifier for this transactable type
  # @!method action_price_per_unit
  #   @return [Boolean] Whether price per unit is available for this transactable type
  # @!method show_page_enabled?
  #   @return [Boolean] Whether the "show" page has been enabled for this listing; if enabled the listing
  #     will have a page separate from the location's
  # @!method translated_bookable_noun
  #   @return [String] represents the item to be booked (e.g. desk, room etc.)
  #     taken from translations (e.g. translation key of the form 'transactable_type.desk.name')
  # @!method translation_key_suffix
  #   @return [String] translation key suffix that is added to translations specific to this transactable type
  # @!method translation_namespace
  #   @return [String] translation namespace that is a prefix for translation keys specific to this transactable type
  # @!method show_date_pickers
  #   @return [Boolean] whether the date pickers (date range) should be shown on search pages
  # @!method searcher_type
  #   @return [String] searcher to be used when searching for transactables of this type; the setting is changeable
  #     from the instance admin / transactable types / search section.
  # @!method slug
  #   @return [String] slug (URL-friendly name) to be used in URLs relating to this TransactableType
  # @!method search_input_name
  #   @return [String] name that will be used (HTML attribute) for the search input on search pages
  # @!method skip_location?
  #   @return [Boolean] whether specifying a location can be skipped for this TransactableType
  # @!method to_param
  #   @return [String] string that will be used in the URLs referring to items of this type
  # @!method action_types
  #   @return [Array<TransactableType::ActionTypeDrop>] array of active action types for this TransactableType
  # @!method allowed_currencies
  #   @return [Array<String>] array of allowed currencies for this TransactableType
  # @!method restrict_countries
  #   @return [Array<String>] array of country codes to which the search for this TransactableType is restricted
  delegate :id, :action_price_per_unit, :show_page_enabled?, :translated_bookable_noun,
           :translation_key_suffix, :translation_namespace, :show_date_pickers, :searcher_type, :slug,
           :search_input_name, :search_field_placeholder, :skip_location?, :to_param,
           :action_types, :allowed_currencies, :restrict_countries, to: :source

  # @return [String] name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def name
    @source.translated_bookable_noun
  end

  # @return [String] the item to be booked (e.g. desk, room etc.)
  def bookable_noun
    name
  end

  # @return [String] string representing the plural of the item to be booked (e.g. desks, rooms etc.),
  #   pluralized, and taken from the translations (e.g. translation key of the form 'transactable_type.desk.name')
  def bookable_noun_plural
    @source.translated_bookable_noun(10)
  end

  # @return [String] search field placeholder as a string
  # @todo - remove in favor of DIY
  def search_field_placeholder
    @source.decorate.search_field_placeholder
  end

  # @return [String] search geolocation field placeholder as a string
  # @todo - remove in favor of DIY
  def geolocation_placeholder
    @source.decorate.geolocation_placeholder
  end

  # @return [String] search full text field placeholder as a string
  # @todo - remove in favor of DIY
  def fulltext_placeholder
    @source.decorate.fulltext_placeholder
  end

  # @return [Boolean] whether the searcher_type is "fulltext_category"
  def fulltext_category_search?
    @source.searcher_type == 'fulltext_category'
  end

  # @return [Boolean] whether the searcher_type is "geo_category"
  def geo_category_search?
    @source.searcher_type == 'geo_category'
  end

  # @return [Boolean] whether the searcher_type has been set to either
  # "fulltext_category" or "geo_category"
  def category_search?
    fulltext_category_search? || geo_category_search?
  end

  # @return [String] JSON formatted representation of the object of
  #   the form !{ id: id_of_object, name: name_of_object }
  # @todo -- this could be a good idea for many other objects -- maybe think about extraction up in the inheritance tree
  def to_json
    {
      id: @source.id,
      name: @source.name
    }.to_json
  end

  # @return [String] lessor name (e.g. 'host') taken from the translations;
  #   key of the form e.g. 'transactable_type.desk.lessor.one'
  # @todo - remove in favor of translations?
  def lessor
    @source.translated_lessor
  end

  # @return [String] lessee name (e.g. 'guest') taken from the translations;
  #   key of the form e.g. 'transactable_type.desk.lessee.one'
  # @todo - remove in favor of translations?
  def lessee
    @source.translated_lessee
  end

  # @return [String] pluralized lessor name taken from the translations;
  #   key of the form e.g. 'transactable_type.desk.lessor.other'
  # @todo - remove in favor of translations?
  def lessors
    @source.translated_lessor(10)
  end

  # @return [String] pluralized lessee name taken from the translations;
  #   key of the form e.g. 'transactable_type.desk.lessee.other'
  # @todo - remove in favor of translations?
  def lessees
    @source.translated_lessee(10)
  end

  # @return [Array<String>] search input types available for this marketplace;
  #   can be included (e.g. include 'home/search/input_name' (see home/search_box_inputs)
  def search_inputs
    return custom_search_inputs if custom_search_inputs.present?
    inputs = []
    inputs << 'geolocation' if @source.searcher_type =~ /geo/
    inputs << 'fulltext' if @source.searcher_type =~ /fulltext/
    inputs << 'categories' if category_search?
    inputs << 'datepickers' if @source.show_date_pickers
    inputs
  end

  # @return [Array<String>] search input types available for this marketplace;
  #   taken from the current context (i.e. set from a liquid filter method like search_box_for)
  # @todo -- deja vu... instance_profile_type_drop.rb:35  :thumbsup:
  def custom_search_inputs
    @context['custom_search_inputs']
  end

  # @return [Array<(String, Integer)>] the container class and input size to be used for the search area
  # of the marketplace's homepage
  # @todo -- deja vu... instance_profile_type_drop.rb:43  :thumbsup:
  def calculate_elements
    sum = 2 # search button
    sum += 4 if search_inputs.include? 'datepickers'
    sum += 2 if search_inputs.include? 'categories'
    sum += 2 if show_transactable_type_picker?
    input_size = 12 - sum # span12
    input_size /= 2 if (%w(geolocation fulltext) & search_inputs).size == 2 # two input fields
    container = input_size == 2 ? 'span12' : 'span10 offset1'
    [container, input_size]
  end

  # @return [String] the container class to be used for the search area
  #   of the marketplace's homepage
  # @todo -- deja vu... instance_profile_type_drop.rb:57  :thumbsup: -- Hardcore copy paste.
  # I dont know which one was first, but we probably dont need those methods in neither places
  # Probably some more are repeating, im leaving this ifle as it is.
  # Look into instance_profile_type_drop for comments to methods that are repeating.
  def calculate_container
    calculate_elements[0]
  end

  # @return [String] the input size to be used for the search area of the
  #   marketplace's homepage (result of the form 'span2' etc.)
  def calculate_input_size
    "span#{calculate_elements[1]}"
  end

  # @return [Boolean] whether this marketplace has multiple service types defined
  def multiple_transactable_types?
    PlatformContext.current.instance.transactable_types.searchable.many?
  end

  # @return [Boolean] whether the transactable type picker should be shown
  def show_transactable_type_picker?
    @context['transactable_type_picker'] != false && multiple_transactable_types? && PlatformContext.current.instance.tt_select_type != 'radio'
  end

  # @return [Array<CategoryDrop>] array of category objects for this marketplace's service types
  def searchable_categories
    @source.categories.searchable.roots
  end

  # @return [Hash{String => Hash{String => String, Array}}] returns hash of categories of the form
  #   !{ "name" => { "name" => 'translated_name', "children" => [collection of chosen values] } }
  def categories
    @categories = build_categories_hash(@source.categories.roots) if @categories.nil?
    @categories
  end

  # @return [Array<CustomAttributeDrop>] array of custom attributes defined for this transactable type
  def custom_attributes
    @source.custom_attributes
  end

  # @return [Hash{String => CustomAttributeDrop}] custom attributes as a hash
  def custom_attributes_as_hash
    Hash[@source.custom_attributes.map { |ca| [ca.name, ca] }]
  end

  # @return [String] class name for this TransactableType object (e.g. 'TransactableType')
  def class_name
    @source.class.name
  end

  # @return [String] value to be used as the id for a per-TransactableType select;
  #   form like 'class_name-ID'
  def select_id
    "#{class_name}-#{id}"
  end

  # @return [Boolean] whether the bulk upload link should be shown according to the
  #   'hidden ui controls' options
  # @todo -- deprecate - DIY
  def show_bulk_upload_link?
    hidden_ui_by_key('dashboard/transactables/bulk_upload').visible?
  end

  # @return [Boolean] whether the search tab should be hidden for the current controller/action (location in the app)
  #   according to the global 'hidden ui controls' rules
  # @todo -- deprecate - DIY
  def show_search_form?
    !hide_tab?('search')
  end

  # @return [String] path to creating a new transactable of this type
  # @todo -- deprecate - url filter
  def new_transactable_path
    routes.new_dashboard_company_transactable_type_transactable_path(@source)
  end

  # @return [String] path to viewing a list of transactables of this type
  # @todo -- deprecate - url filter
  def transactable_types_path
    routes.dashboard_company_transactable_type_transactables_path(@source)
  end

  # @return [String] path to the space wizard for listing an initial item of this type
  # @todo -- deprecate - url filter
  def space_wizard_path
    routes.transactable_type_space_wizard_list_path(@source)
  end

  # @return [String] path to a new bulk upload for this transactable type
  # @todo -- deprecate - url filter
  def new_data_upload_path
    routes.new_dashboard_company_transactable_type_data_upload_path(@source)
  end
end
