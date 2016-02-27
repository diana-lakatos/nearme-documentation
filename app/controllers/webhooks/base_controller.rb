class Webhooks::BaseController < ActionController::Base

  def test
    render text: "json: #{params.inspect}"
  end

end

