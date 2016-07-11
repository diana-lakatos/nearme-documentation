class Spree::ProductTypeDecorator < TransactableTypeDecorator
  include Draper::LazyHelpers

  delegate_all

  def manage_transactables_path
    [:dashboard, :company, object, :products]
  end

  def search_field_placeholder
    I18n.t 'homepage.search_field_placeholder.search'
  end

end
