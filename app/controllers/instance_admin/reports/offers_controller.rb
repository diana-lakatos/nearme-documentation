class InstanceAdmin::Reports::OffersController < InstanceAdmin::Reports::BaseController

  private

  def set_scopes
    @search_form = InstanceAdmin::OfferSearchForm
    @scope_type_class = OfferType
    @scope_class = Offer
  end
end

