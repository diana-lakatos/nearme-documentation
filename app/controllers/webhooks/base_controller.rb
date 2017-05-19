# frozen_string_literal: true
class Webhooks::BaseController < ActionController::Base
  include RaygunExceptions

  def test
    render text: "json: #{params.inspect}"
  end
end
