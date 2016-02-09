class ApprovalRequestDecorator < Draper::Decorator

  include Rails.application.routes.url_helpers
  include Draper::LazyHelpers

  delegate_all

  def owner_class
    if Transactable === owner
      "Service (#{owner.try(:transactable_type).try(:name)})"
    else
      owner.class.name
    end
  end

  def login_as_owner_creator_link
    if owner === User
      creator = owner
    else
      creator = owner.try(:creator)
    end

    if creator.present?
      link_to "Login As Creator", login_as_instance_admin_manage_user_path(creator), :method => :post,
        data: { confirm: 'This will log you out and re-log you in as this user' }
    else
      ""
    end
  end

  def owner_name
    name = owner.try(:name).try(:truncate, 25)
    link = '#'

    case owner
    when Transactable
      link = owner.decorate.show_path
    when Company
      if owner.creator.present?
        link = user_path(owner.creator)
      end
    when User
      link = user_path(owner)
    end

    link_to name, link
  end


end
