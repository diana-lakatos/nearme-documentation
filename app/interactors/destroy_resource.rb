# frozen_string_literal: true
class DestroyResource
  def initialize(resource:, params:, current_user:)
    # TODO: store event etc
    @resource = resource
    @params = params
  end

  def call
    @resource.destroy
  end
end
