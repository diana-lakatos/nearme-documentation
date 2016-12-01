module LiquidFormHelpers
  # http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-options_for_select
  def options_for_select(*args)
    form_helper.options_for_select(*args)
  end

  private

  class RailsFormHelpersProxy
    include ActionView::Helpers::FormOptionsHelper
  end

  def form_helper
    RailsFormHelpersProxy.new
  end
end
