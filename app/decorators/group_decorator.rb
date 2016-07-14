class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def role_of_user(user)
    return :owner if is_owner?(user)
    is_moderator?(user) ? :moderator : :member
  end

  def is_moderator?(user)
    user.membership_for(model).moderator
  end

  def is_owner?(user)
    model.creator_id.eql?(user.id)
  end

  def button_join_name
    model.public? ? t('group.join') : t('group.ask_to_join')
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end

end
