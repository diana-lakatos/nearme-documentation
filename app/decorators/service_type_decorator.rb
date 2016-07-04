class ServiceTypeDecorator < TransactableTypeDecorator
  include Draper::LazyHelpers

  delegate_all



end