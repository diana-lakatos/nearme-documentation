module PaymentDocumentsHelper
  def class_for_active_tab(params_action)
    'active' if params[:action] == params_action
  end
end
