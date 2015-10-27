class TransactableTypeDrop < BaseDrop

  attr_reader :transactable_type

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
  delegate :id, :buyable?, :action_price_per_unit, :show_page_enabled?, :translated_bookable_noun,
    :translation_key_suffix, :translation_namespace, :show_date_pickers, :searcher_type, :slug, to: :transactable_type

  def initialize(transactable_type)
    @transactable_type = transactable_type
    @decorated = @transactable_type.decorate
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def name
    @transactable_type.translated_bookable_noun
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def bookable_noun
    name
  end

  # name (plural) for the bookable item this transactable type represents (e.g. desks, rooms etc.)
  def bookable_noun_plural
    @transactable_type.translated_bookable_noun(10)
  end

  # search field placeholder as a string
  def search_field_placeholder
    @decorated.search_field_placeholder
  end

  # returns true if searcher_type is "fulltext_category"
  def fulltext_category_search?
    @transactable_type.searcher_type == 'fulltext_category'
  end

  # returns true if searcher_type is "geo_category"
  def geo_category_search?
    @transactable_type.searcher_type == 'geo_category'
  end

  # returns true if searcher_type has been set to either
  # "fulltext_category" or "geo_category"
  def category_search?
    fulltext_category_search? || geo_category_search?
  end

  def to_json
    {
      id: @transactable_type.id,
      name: @transactable_type.name
    }.to_json
  end

  def lessor
    @transactable_type.translated_lessor
  end

  def lessee
    @transactable_type.translated_lessee
  end

  def lessors
    @transactable_type.translated_lessor(10)
  end

  def lessees
    @transactable_type.translated_lessee(10)
  end

  def search_inputs
    return custom_search_inputs if custom_search_inputs.present?
    inputs = []
    inputs << 'geolocation' if @transactable_type.searcher_type =~ /geo/
    inputs << 'fulltext' if @transactable_type.searcher_type =~ /fulltext/
    inputs << 'categories' if category_search?
    inputs << 'datepickers' if @transactable_type.show_date_pickers
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
    @transactable_type.categories.searchable.roots
  end

end
