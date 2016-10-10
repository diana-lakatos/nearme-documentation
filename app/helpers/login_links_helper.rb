module LoginLinksHelper
  def get_return_to_url(default_url = nil, options = {})
    return_path = url_for
    if (return_path == '/' || in_signed_in_or_sign_up?) && default_url.present? && TransactableType.first.try(:single_transactable)
      return_path = default_url
    end
    in_signed_in_or_sign_up? ? { return_to: default_url }.merge(options) : { return_to: return_path }.merge(options)
  end

  def in_signed_in_or_sign_up?
    in_signed_in? || in_sign_up?
  end

  def in_signed_in?
    params[:controller] == 'sessions'
  end

  def in_sign_up?
    params[:controller] == 'registrations' && params[:action] == 'new'
  end
end
