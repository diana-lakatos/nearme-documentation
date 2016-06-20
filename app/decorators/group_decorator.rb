class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def button_join_name
    model.public? ? t('group.join') : t('group.ask_to_join')
  end

end
