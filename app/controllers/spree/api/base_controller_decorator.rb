Spree::Api::BaseController.class_eval do

  def try_spree_current_user
    current_user.try(:decorate)
  end

end
