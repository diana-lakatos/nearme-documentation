class Category < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_nested_set dependent: :destroy

  DISPLAY_OPTIONS = %w(tree autocomplete).freeze
  SEARCH_OPTIONS = [["Include in search", "include"], ["Exclude from search", "exclude"]].freeze

  has_many :categories_transactables
  has_many :categories_products
  has_many :products, through: :categories_products
  has_many :transactables, through: :categories_transactables

  belongs_to :instance

  # Validation
  validates :name, presence: true


  # Polymprophic association to TransactableType, ProductType
  belongs_to :categorable, polymorphic: true
  belongs_to :instance

  before_save :set_permalink
  after_save :create_translation_key

  # Scopes

  scope :mandatory, -> { where(mandatory: true) }
  scope :products, -> { where(categorable_type: 'Spree::ProductType') }
  scope :searchable, -> { where(search_options: 'include') }
  scope :services, -> { where(categorable_type: 'TransactableType') }
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
    "#{Translation::CUSTOM_PREFIX}.categories.#{name.to_url.gsub(/[\-|\/|\.]/, '_').downcase}"
  end

  def create_translation_key
    instance.locales.each do |locale|
      translation_attributes = {  locale: locale.code, key: translation_key}
      @translation = instance.translations.where(translation_attributes).presence ||
        instance.translations.create(translation_attributes.merge(value: name))
    end
  end
end

