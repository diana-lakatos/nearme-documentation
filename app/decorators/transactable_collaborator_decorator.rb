class TransactableCollaboratorDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

end
