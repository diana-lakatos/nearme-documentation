class UserProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def customizations_for(custom_model)
    customizations.select{|c| c.custom_model_type == custom_model}.sort_by{ |c| c.created_at || 1.day.from_now }
  end

end
