class DeleteElbJob < Job
  def after_initialize(name)
    @name = name
  end

  def perform
    b = NearMe::Balancer.new(name: @name)
    b.delete!
  end
end
