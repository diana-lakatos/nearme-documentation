class InstanceAdmin::Manage::BaseController < InstanceAdmin::ResourceController
  CONTROLLERS = { 'inventories' => { default_action: 'index' },
                  'transfers'   => { default_action: 'index' },
                  'partners'    => { default_action: 'index' },
                  'users'       => { default_action: 'index' }}
end
