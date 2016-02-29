class Constraints::TransactableTypeConstraints
  def matches?(request)
    params = request.path_parameters
    params[:transactable_type_id].present? ? ServiceType.where(slug: params[:transactable_type_id]).exists? : false
  end
end
