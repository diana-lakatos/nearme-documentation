module Constraints
  class TransactableTypeConstraints
    def matches?(request)
      params = request.path_parameters
      params[:transactable_type_id].present? ? TransactableType.where(slug: params[:transactable_type_id]).exists? : false
    end
  end
end
