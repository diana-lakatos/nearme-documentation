class InstanceAdmin::Manage::BaseController < InstanceAdmin::ResourceController
  CONTROLLERS = { 'inventories' => { controller: '/instance_admin/manage/inventories', default_action: 'index' },
                  'transfers'   => { controller: '/instance_admin/manage/transfers', default_action: 'index' },
                  'partners'    => { controller: '/instance_admin/manage/partners', default_action: 'index' },
                  'users'       => { controller: '/instance_admin/manage/users', default_action: 'index' },
                  'emails' => { controller: '/instance_admin/manage/email_templates', default_action: 'index' },
                  'support' => { controller: '/instance_admin/manage/support', default_action: 'index' },
                  'faq' => { controller: '/instance_admin/manage/support/faqs', default_action: 'index' }}

  def index
    redirect_to instance_admin_manage_inventories_path
  end
end
