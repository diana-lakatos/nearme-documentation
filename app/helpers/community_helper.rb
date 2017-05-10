module CommunityHelper
  def prepare_search_url(extra_params = {})
    extra_params[:query] = params[:query]
    search_url(extra_params)
  end

  def address_for_user_card(address)
    if address.try(:city).present? && address.try(:state).present?
      "#{address.city}, #{address.state}"
    else
      address.try(:address)
    end
  end

  def community_user_category
    Category.where(parent_id: nil, name: 'Categories').first
  end
end
