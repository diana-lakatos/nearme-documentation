class RaygunDeployNotifier
  def self.send!

    uri = URI("https://app.raygun.io/deployments?authToken=#{Rails.application.config.raygun_api_token}")

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'

    options = {
      'version': Rails.application.config.app_version,
      'ownerName': `git --no-pager show -s --format='%an' HEAD`.strip,
      'emailAddress': `git --no-pager show -s --format='%ae' HEAD`.strip,
      'comment': `git log -1 --pretty=%B`.strip,
      'scmIdentifier': `git rev-parse --verify HEAD`.strip
    }

    begin
      # Notify Rails App Tracker
      options[:apiKey] = Rails.application.config.raygun_api_key
      request.body = options.to_json
      http.request(request)

      # Notify JS Tracker
      options[:apiKey] = Rails.application.config.raygun_js_api_key
      request.body = options.to_json
      http.request(request)
    rescue
      puts 'Unable to notify Raygun about deployment'
    end
  end
end
