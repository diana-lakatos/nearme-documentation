class TransactableType < ActiveRecord::Base
  self.inheritance_column = :type
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_custom_attributes_set

  AVAILABLE_TYPES = ['Listing', 'Buy/Sell']

  attr_accessor :enable_cancellation_policy

  has_many :form_components, as: :form_componentable
  has_many :data_uploads, as: :importable, dependent: :destroy
  has_many :rating_systems
  has_many :reviews
  has_many :instance_views
  has_many :categories, as: :categorable, dependent: :destroy
  has_many :custom_validators, as: :validatable

  belongs_to :instance

  serialize :custom_csv_fields, Array
  serialize :allowed_currencies, Array

  after_update :destroy_translations!, if: lambda { |transactable_type| transactable_type.name_changed? }

  validates_presence_of :name

  scope :products, -> { where(type: 'Spree::ProductType') }
  scope :services, -> { where(type: 'ServiceType') }

  def any_rating_system_active?
    self.rating_systems.any?(&:active)
  end

  def allowed_currencies
    super || instance.allowed_currencies
  end

  def allowed_currencies=currencies
    currencies.reject!(&:blank?)
    super(currencies)
  end

  def default_currency
    super.presence || instance.default_currency.presence || 'USD'
  end

  def destroy_translations!
    ids = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, "%.#{self.translation_key_suffix_was}.%", "%.#{self.translation_key_pluralized_suffix_was}.%").inject([]) do |ids_to_delete, t|
      if t.key  =~ /\Asimple_form\.(.+).#{self.translation_key_suffix_was}\.(.+)\z/ || t.key  =~ /\Asimple_form\.(.+).#{self.translation_key_pluralized_suffix_was}\.(.+)\z/
          ids_to_delete << t.id
      end
      ids_to_delete
    end
    Translation.destroy(ids)
    custom_attributes.reload.each(&:create_translations)
  end

  def self.mandatory_boolean_validation_rules
    { "inclusion" => { "in" => [true, false], "allow_nil" => false } }
  end

  def to_liquid
    raise NotImplementedError.new('Abstract method')
  end

  def has_action?(name)
    action_rfq?
  end

  def bookable_noun_plural
    (bookable_noun.presence || name).pluralize
  end

  def create_rating_systems
    [instance.lessor, instance.lessee, name].each do |subject|
      rating_system = instance.rating_systems.create(subject: subject, transactable_type_id: id)
      RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create(value: value, instance: instance) }
    end
  end

end

