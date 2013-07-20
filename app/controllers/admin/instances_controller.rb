class Admin::InstancesController < Admin::ResourceController
  before_filter :build_domain, only: [:new]

  def build_domain
    build_resource.domains.build
  end

end

