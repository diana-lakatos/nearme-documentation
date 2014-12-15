module HttpLocalhost
  def disable_remote_http
    WebMock.disable_net_connect!(:allow_localhost => true, :allow => "codeclimate.com")
  end

  def show_page
    save_page Rails.root.join( 'public', 'capybara.html' )
    %x(launchy http://localhost:3000/capybara.html)
  end

end

World(HttpLocalhost)
