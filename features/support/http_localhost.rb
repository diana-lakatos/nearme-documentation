module HttpLocalhost
  def disable_remote_http
    WebMock.disable_net_connect!(:allow_localhost => true, :allow => "codeclimate.com")
  end
end

World(HttpLocalhost)
