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


  # Polymprophic association to TransactableType, ProductType
  belongs_to :categorizable, polymorphic: true
  belongs_to :instance

  before_save :set_permalink
  after_save :create_translation_key

  # Scopes

  scope :mandatory, -> { where(mandatory: true) }
  scope :products, -> { where(categorizable_type: 'Spree::ProductType') }
  scope :searchable, -> { where(search_options: 'include') }
  scope :services, -> { where(categorizable_type: 'TransactableType') }
  scope :users, -> { where(shared_with_users: true) }

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
    I18n.t(translation_key)
  end

  def to_liquid
    CategoryDrop.new(self)
  end

  def set_permalink
    if parent.present?
      self.permalink = [parent.permalink, name.to_url].join('/')
    else
      self.permalink = name.to_url
    end
  end

  def translation_key
    "categories.#{name.to_url.gsub(/[\-|\/|\.]/, '_').downcase}"
  end

  def create_translation_key
    instance.locales.each do |locale|
      translation_attributes = {  locale: locale.code, key: translation_key}
      @translation = instance.translations.where(translation_attributes).presence ||
        instance.translations.create(translation_attributes.merge(value: name))
    end
  end
end

