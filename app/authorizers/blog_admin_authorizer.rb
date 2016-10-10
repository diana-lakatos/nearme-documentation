class BlogAdminAuthorizer < Authorizer
  def authorized?
    return true if instance_owner?
    return true if instance_admin && instance_admin_role && instance_admin_role.permission_blog
    false
  end
end
