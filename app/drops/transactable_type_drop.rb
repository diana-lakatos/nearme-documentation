class TransactableTypeDrop < BaseDrop
  include CategoriesHelper

  # id
  #   numeric identifier for this transactable type
  # show_page_enabled?
  #   returns true whether the "show" page has been enabled for this listing
  #   if enabled the listing will have a page separate from the location's
  # translation_key_suffix
  #   translation key suffix that is added to translations specific to this transactable type
  # translation_namespace
  #   translation namespace that is a prefix for translation keys specific to this transactable type
  # translated_bookable_noun
  #   translated name of this transactable type, based on current language
  delegate :id, :action_price_per_unit, :show_page_enabled?, :translated_bookable_noun,
    :translation_key_suffix, :translation_namespace, :show_date_pickers, :searcher_type, :slug,
    :search_input_name, :search_field_placeholder, :skip_location?, to: :source

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def name
    @source.translated_bookable_noun
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def bookable_noun
    name
  end

  # name (plural) for the bookable item this transactable type represents (e.g. desks, rooms etc.)
  def bookable_noun_plural
    @source.translated_bookable_noun(10)
  end

  # search field placeholder as a string
  def search_field_placeholder
    @source.decorate.search_field_placeholder
  end

  # search geolocation field placeholder as a string
  def geolocation_placeholder
    @source.decorate.geolocation_placeholder
  end

  # search full text field placeholder as a string
  def fulltext_placeholder
    @source.decorate.fulltext_placeholder
  end

  # returns true if searcher_type is "fulltext_category"
  def fulltext_category_search?
    @source.searcher_type == 'fulltext_category'
  end

  # returns true if searcher_type is "geo_category"
  def geo_category_search?
    @source.searcher_type == 'geo_category'
  end

  # returns true if searcher_type has been set to either
  # "fulltext_category" or "geo_category"
  def category_search?
    fulltext_category_search? || geo_category_search?
  end

  def to_json
    {
      id: @source.id,
      name: @source.name
    }.to_json
  end

  def lessor
    @source.translated_lessor
  end

  def lessee
    @source.translated_lessee
  end

  def lessors
    @source.translated_lessor(10)
  end

  def lessees
    @source.translated_lessee(10)
  end

  def search_inputs
    return custom_search_inputs if custom_search_inputs.present?
    inputs = []
    inputs << 'geolocation' if @source.searcher_type =~ /geo/
    inputs << 'fulltext' if @source.searcher_type =~ /fulltext/
    inputs << 'categories' if category_search?
    inputs << 'datepickers' if @source.show_date_pickers
    inputs
  end

  def custom_search_inputs
    @context['custom_search_inputs']
  end

  # returns the container class and input size to be used for the search area
  # of the marketplace's homepage
  def calculate_elements
    sum = 2 #search button
    sum += 4 if search_inputs.include? 'datepickers'
    sum += 2 if search_inputs.include? 'categories'
    sum += 2 if show_transactable_type_picker?
    input_size = 12 - sum #span12
    input_size /= 2 if (['geolocation', 'fulltext'] & search_inputs).size == 2 #two input fields
    container = input_size == 2 ? "span12" : "span10 offset1"
    [container, input_size]
  end

  # returns the container class to be used for the search area
  # of the marketplace's homepage
  def calculate_container
    calculate_elements[0]
  end

  # returns the input size to be used for the search area of the
  # marketplace's homepage
  def calculate_input_size
    "span#{calculate_elements[1]}"
  end

  # returns true if this marketplace has multiple service types defined
  def multiple_transactable_types?
    PlatformContext.current.instance.transactable_types.searchable.many?
  end

  # returns true if transactable type picker should be shown
  def show_transactable_type_picker?
    @context["transactable_type_picker"] != false && multiple_transactable_types? && PlatformContext.current.instance.tt_select_type != 'radio'
  end

  # array of category objects for this marketplace's service types
  def searchable_categories
    @source.categories.searchable.roots
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name', "children" => [<collection of chosen values] } }
  def categories
    if @categories.nil?
      @categories = build_categories_hash(@source.categories.roots)
    end
    @categories
  end

  def custom_attributes
    @source.custom_attributes
  end

  def class_name
    @source.class.name
  end

  def select_id
    "#{class_name}-#{id}"
  end

  def show_bulk_upload_link?
    hidden_ui_by_key('dashboard/transactables/bulk_upload').visible?
  end

  def show_search_form?
    !hide_tab?('search')
  end

  def new_transactable_path
    routes.new_dashboard_company_transactable_type_transactable_path(@source)
  end

  def transactable_types_path
    routes.dashboard_company_transactable_type_transactables_path(@source)
  end

  def new_data_upload_path
    routes.new_dashboard_company_transactable_type_data_upload_path(@source)
  end

end
