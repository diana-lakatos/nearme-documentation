require 'nearme'

class DeleteElbJob < Job
  def after_initialize(name)
    @name = name
  end

  def perform
    return true if Rails.env.development?

    b = NearMe::Balancer.new(name: @name)
    b.delete!
  end
end
