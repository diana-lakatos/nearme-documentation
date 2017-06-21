# frozen_string_literal: true
class AdminPermissionedUrls
  include Rails.application.routes.url_helpers

  def initialize(permission)
    @permission = permission
  end

  def url
    case @permission
    when 'blog'
      polymorphic_path([:instance_admin, :manage_blog])
    when 'support'
      polymorphic_path([:instance_admin, :support, :root])
    when 'shippingoptions'
      polymorphic_path([:instance_admin, :settings, :shippings, :shipping_providers])
    when 'reports'
      polymorphic_path([:instance_admin, :reports, :transactables])
    when 'groups'
      polymorphic_path([:instance_admin, :groups, :groups])
    else
      polymorphic_path([:instance_admin, @permission])
    end
  end
end
