class OfferType < TransactableType
  SEARCH_VIEWS = %w(offers)

  has_many :offers, dependent: :destroy, foreign_key: 'transactable_type_id'


  def available_search_views
    SEARCH_VIEWS
  end

  def to_liquid
    @offer_type_drop ||= OfferTypeDrop.new(self)
  end

  def wizard_path(options = {})
    "/offer_types/#{id}/offer_wizard/new"
  end

  private

  def set_default_options
    super
    self.searcher_type ||= 'geo'
  end
end
