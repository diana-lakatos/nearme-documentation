# frozen_string_literal: true
class InstanceProfileTypeDrop < BaseDrop
  # @return [InstanceProfileTypeDrop]
  attr_reader :instance_profile_type

  # @!method id
  #   @return [Integer] numeric identifier for this instance profile type
  # @!method profile_type
  #   @return [String] Type of instance profile (seller, buyer, default)
  delegate :id, :profile_type, to: :instance_profile_type

  def initialize(instance_profile_type)
    @instance_profile_type = instance_profile_type
    @decorated = @instance_profile_type.decorate
  end

  # @return [String] name from translations
  def name
    @instance_profile_type.translated_bookable_noun(1)
  end

  # @return (see InstanceProfileTypeDrop#name)
  def bookable_noun
    name
  end

  # @return [Array<String>] ['fulltext']
  # @todo -- investigate if this is necessary - easy to hardcode in DIY
  def search_inputs
    ['fulltext']
  end

  # @return [String] custom_search_inputs value in the current context
  # @todo Investigate and remove invalid method
  def custom_search_inputs
    @context['custom_search_inputs']
  end

  # @return [Array<(String, Integer)>] the container class and input size to be used for the
  #   search area of the marketplace's homepage
  # @todo -- depracate whole or some parts -- old bootstrap classes, hardcoded strings
  # IMO some of this functionality can be done using css
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
  # @todo -- depracate
  def calculate_container
    calculate_elements[0]
  end

  # @return [Integer] the input size to be used for the search area of the
  #   marketplace's homepage
  # @todo -- depracate
  def calculate_input_size
    "span#{calculate_elements[1]}"
  end

  # @return [Boolean] whether this marketplace has multiple service types defined
  # @todo -- depracate (can be done easily by DIY using instance.tt.searchable.size > 0)
  def multiple_transactable_types?
    PlatformContext.current.instance.transactable_types.searchable.many?
  end

  # @return [Boolean] whether transactable type picker should be shown
  # @todo -- depracate
  def show_transactable_type_picker?
    @context['transactable_type_picker'] != false && multiple_transactable_types? && PlatformContext.current.instance.tt_select_type != 'radio'
  end

  # @return [String] instance profile type class name
  # @todo -- depracate?
  def class_name
    @instance_profile_type.class.name
  end

  # @return [String] id to be used for a corresponding form element
  # @todo -- depracate?
  def select_id
    "#{class_name}-#{id}"
  end

  # @return [Array<CategoryDrop>] searchable categories for the instance profile type
  def searchable_categories
    @instance_profile_type.categories.searchable.roots
  end

  # @return [Hash{String => CustomAttributeDrop}] custom attributes as a hash
  def custom_attributes_as_hash
    Hash[@instance_profile_type.custom_attributes.map { |ca| [ca.name, ca] }]
  end

end
