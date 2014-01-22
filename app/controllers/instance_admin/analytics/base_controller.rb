class InstanceAdmin::Analytics::BaseController < InstanceAdmin::BaseController
  CONTROLLERS = { 'overview' => { default_action: 'show' }}
end
