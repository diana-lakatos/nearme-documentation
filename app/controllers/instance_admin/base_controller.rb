class InstanceAdmin::BaseController < ApplicationController
  before_filter :authenticate_user!
  # TODO: further authentication will be introduced later

  layout 'instance_admin'

end

