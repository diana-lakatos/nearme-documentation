# See web_mock_twitter_fake.rb which supplies the following methods:
#
# stub_http_request_for_fake_twitter
#
module TwitterFake

  BASE_URL = "https://api.twitter.com"

  def disable_remote_http
    WebMock.disable_net_connect!
  end

  def stub_http_request_for_fake_twitter(method, url, response_options)
    WebMock.stub_request(method, url).to_return(response_options)
  end

  def stub_twitter_verify_credentials_for(options)
    twitter_username = options.delete(:twitter_username)
    twitter_id = options.delete(:twitter_id)
    response_json = <<-JSON
      {
        "screen_name":"#{twitter_username}",
        "id":"#{twitter_id}",
        "profile_image_url":"http://a3.twimg.com/profile_images/518003899/username_normal.png"
      }
    JSON

    verify_credentials_url = BASE_URL + '/1/account/verify_credentials.json'
    stub_http_request_for_fake_twitter(:get, verify_credentials_url, {
      :status => 200,
      :body => response_json
    })
  end

  def stub_twitter_request_token
    stub_http_request_for_fake_twitter(:any, "#{BASE_URL}/oauth/request_token", {
      :status => 200,
      :body => "oauth_token=this_need_not_be_real&oauth_token_secret=same_for_this"
    })
  end

  def stub_twitter_successful_access_token
    stub_http_request_for_fake_twitter(:any, "#{BASE_URL}/oauth/access_token", {
      :status => 200,
      :body => "oauth_token=this_need_not_be_real&oauth_token_secret=same_for_this"
    })
  end

  def stub_twitter_denied_access_token
    stub_http_request_for_fake_twitter(:any, "#{BASE_URL}/oauth/access_token", {
      :status => 401,
      :body => ''
    })
  end

end

World(TwitterFake)
