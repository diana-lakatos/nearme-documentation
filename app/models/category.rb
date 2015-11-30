class Category < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_nested_set dependent: :destroy, order: :position

  DISPLAY_OPTIONS = %w(tree autocomplete).freeze
  SEARCH_OPTIONS = [["Include in search", "include"], ["Exclude from search", "exclude"]].freeze

  has_many :categories_categorizables
  has_many :categorizable_products, through: :categories_categorizables, source_type: "Spree::Product"
  has_many :categorizable_transactables, through: :categories_categorizables, source_type: "Transactable"

  belongs_to :instance

  # Validation
  validates :name, presence: true

  has_many :category_linkings
  has_many :service_types, through: :category_linkings
  has_many :product_types, through: :category_linkings, class_name: 'Spree::ProductType'
  has_many :project_types, through: :category_linkings
  has_many :instance_profile_types, through: :category_linkings

  belongs_to :instance

  before_save :set_permalink
  after_save :children_update
  after_save :create_translation_key
  after_save :rename_form_component, if: -> (category) { category.name_changed? }
  after_destroy :rename_form_component, :remove_translation_key

  # Scopes

  scope :mandatory, -> { where(mandatory: true) }
  scope :products, -> { joins(:category_linkings).where(category_linkings: { category_linkable_type: 'Spree::ProductType' } ) }
  scope :searchable, -> { where(search_options: 'include') }
  scope :services, -> { joins(:category_linkings).where(category_linkings: { category_linkable_type: 'ServiceType' } ) }
  scope :users, -> { joins(:category_linkings).where(category_linkings: { category_linkable: PlatformContext.current.instance.default_profile_type } ) }
  scope :sellers, -> { joins(:category_linkings).where(category_linkings: { category_linkable: PlatformContext.current.instance.seller_profile_type } ) }
  scope :buyers, -> { joins(:category_linkings).where(category_linkings: { category_linkable: PlatformContext.current.instance.buyer_profile_type } ) }

  def autocomplete?
    self.display_options == 'autocomplete'
  end

  def child_index=(idx)
    unless self.new_record?
      if parent
        move_to_child_with_index(parent, idx.to_i)
      else
        move_to_root
      end
    end
  end

  def name=(name)
    super(name.try(:strip))
  end

  def encoded_permalink
    permalink.gsub("/", "%2F")
  end

  def include_in_search?
    self.search_options.include?("include")
  end

  def pretty_name
    ancestor_chain = self.ancestors.inject("") do |name, ancestor|
      name += "#{ancestor.translated_name} -> "
    end
    ancestor_chain + translated_name
  end

  def self_and_descendants
    super.where(instance_id: instance_id)
  end

  def translated_name
    I18n.t(translation_key, default: name)
  end

  def to_liquid
    @category_drop ||= CategoryDrop.new(self)
  end

  def set_permalink
    if parent.present?
      self.permalink = [parent.permalink, name.to_url].join('/')
    else
      self.permalink = name.to_url
    end
  end

  def children_update
    self.children.each(&:save)
  end

  def translation_key
    "categories.#{name.to_url.to_yml_key}"
  end

  def translation_key_was
    "categories.#{name_was.to_url.to_yml_key}"
  end

  def create_translation_key
    remove_translation_key if name_changed? && name_was
    instance.locales.each do |locale|
      translation_attributes = { locale: locale.code, key: translation_key }
      instance.translations.find_or_create_by(translation_attributes) { |t| t.value = name }
    end
  end

  def remove_translation_key
    instance.translations.where(locale: instance.locales.map(&:code), key: translation_key_was).destroy_all
  end

  def rename_form_component
    category_linkings.find_each do |category_linking|
      categorizable = category_linking.category_linkable
      if categorizable.try(:form_components)
        categorizable.form_components.each do |fc|
          old_field = fc.form_fields.select{|pair| pair.first[1] =~ /Category - #{name_was}$/}
          if old_field.present?
            if deleted_at
              fc.form_fields.delete(old_field[0])
            else
              old_field[0].values[0].gsub!(name_was, name)
            end
            fc.save!
          end
        end
      end
    end
  end

end

