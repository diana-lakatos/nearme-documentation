module CommunityHelper

  def prepare_search_url(extra_params = {})
    extra_params[:query] = params[:query]
    search_url(extra_params)
  end

  def address_for_user_card(address)
    if address.city.present? && address.state.present?
      "#{address.city}, #{address.state}"
    else
      address.address
    end
  end

end
