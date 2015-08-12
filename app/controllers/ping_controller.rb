class PingController < ActionController::Base
  newrelic_ignore only: [:index]

  def index
    render text: 'pong'
  end
end
