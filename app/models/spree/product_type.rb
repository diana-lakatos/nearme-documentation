class Spree::ProductType < TransactableType

  has_many :form_components, as: :form_componentable
  has_many :products, dependent: :destroy, class_name: "Spree::Product", inverse_of: :product_type

  SEARCH_VIEWS = %w(products products_table products_list)

  belongs_to :user

  def wizard_path
    "/product_types/#{id}/product_wizard/new"
  end

  def buyable?
    true
  end

  def create_rating_systems
    [RatingConstants::HOST, RatingConstants::TRANSACTABLE].each do |subject|
      rating_system = self.rating_systems.create!(subject: subject)
      RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create!(value: value) }
    end
  end

  def to_liquid
    @spree_product_type_drop ||= Spree::ProductTypeDrop.new(self)
  end

  def lessor
    I18n.t('buy_sell_market.seller', :default => 'seller')
  end

  def lessee
    I18n.t('buy_sell_market.buyer', :default => 'buyer')
  end

  def available_search_views
    SEARCH_VIEWS
  end

  private

  def set_default_options
    super
    self.searcher_type ||= 'fulltext'
  end

end
