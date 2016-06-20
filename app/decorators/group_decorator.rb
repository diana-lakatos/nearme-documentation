class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def is_owner?(user_id)
    model.creator_id.eql?(user_id)
  end

  def button_join_name
    model.public? ? t('group.join') : t('group.ask_to_join')
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end

end
