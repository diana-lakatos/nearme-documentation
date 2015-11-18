class Constraints::TransactableTypeConstraints
  def matches?(request)
    params = request.path_parameters
    params[:transactable_type_id].present? ? TransactableType.find_by(slug: params[:transactable_type_id]).present? : false
  end
end
