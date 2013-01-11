# See web_mock_linkedin_fake.rb which supplies the following methods:
#
# stub_http_request_for_fake_linkedin
#
module LinkedinFake

  LINKEDIN_BASE_URL = "https://api.linkedin.com"

  def disable_remote_http
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  def stub_http_request_for_fake_linkedin(method, url, response_options)
    WebMock.stub_request(method, url).to_return(response_options)
  end

  def stub_linkedin_verify_credentials_for(options)
    linkedin_username = options.delete(:linkedin_username)
    linkedin_id = options.delete(:linkedin_id)
    response_json = <<-JSON
      {
        "screen_name":"#{linkedin_username}",
        "user_id":"hello",
        "id":"#{linkedin_id}",
        "profile_image_url":"http://a3.twimg.com/profile_images/518003899/username_normal.png"
      }
    JSON

    verify_credentials_url = LINKEDIN_BASE_URL + '/1/account/verify_credentials.json'
    stub_http_request_for_fake_linkedin(:get, verify_credentials_url, {
      :status => 200,
      :body => response_json
    })
  end

  def stub_linkedin_request_token
    stub_http_request_for_fake_linkedin(:any, "#{LINKEDIN_BASE_URL}/oauth/request_token", {
      :status => 200,
      :body => "oauth_token=this_need_not_be_real&oauth_token_secret=same_for_this"
    })
  end

  def stub_linkedin_successful_access_token(user_id = nil)
    stub_http_request_for_fake_linkedin(:any, "#{LINKEDIN_BASE_URL}/oauth/access_token", {
      :status => 200,
      :body => "oauth_token=this_need_not_be_real&oauth_token_secret=same_for_this&user_id=#{user_id}"
    })
  end

  def stub_linkedin_denied_access_token
    stub_http_request_for_fake_linkedin(:any, "#{LINKEDIN_BASE_URL}/oauth/access_token", {
      :status => 401,
      :body => ''
    })
  end

end

World(LinkedinFake)
