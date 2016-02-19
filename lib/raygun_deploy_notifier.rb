class RaygunDeployNotifier
  def self.send!
    send_request(Rails.application.config.raygun_api_key, 'Rails app')
    send_request(Rails.application.config.raygun_js_api_key, 'JS app')
  end

  private

  def self.send_request(apiKey, env)
    uri = URI("https://app.raygun.io/deployments?authToken=#{Rails.application.config.raygun_api_token}")

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'

    request.body = {
      'version': Rails.application.config.app_version,
      'ownerName': `git --no-pager show -s --format='%an' HEAD`.strip,
      'emailAddress': `git --no-pager show -s --format='%ae' HEAD`.strip,
      'comment': `git log -1 --pretty=%B`.strip,
      'scmIdentifier': `git rev-parse --verify HEAD`.strip,
      'apiKey': apiKey
    }.to_json

    begin
      http.request(request)
      puts "Success: Notified Raygun #{env} about deployment"
    rescue
      puts "Error: Unable to notify Raygun #{env} about deployment!"
    end
  end

end
