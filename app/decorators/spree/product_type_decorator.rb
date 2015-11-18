class Spree::ProductTypeDecorator < TransactableTypeDecorator
  include Draper::LazyHelpers

  delegate_all

end