class InstanceAdmin::Manage::BaseController < InstanceAdmin::ResourceController
  CONTROLLERS = { 'inventories' => { default_action: 'index' },
                  'transfers'   => { default_action: 'index' },
                  'partners'    => { default_action: 'index' },
                  'users'       => { default_action: 'index' }}

  def index
    redirect_to instance_admin_manage_inventories_path
  end
end
