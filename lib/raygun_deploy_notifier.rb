class RaygunDeployNotifier
  RAYGUN_JS_API_KEY = 'G/Y1+vaVvETUu7/5alKYZw=='.freeze
  RAYGUN_API_KEY = 'Wh44tvzgPN/Ea/JJN/i4JQ=='.freeze
  RAYGUN_API_TOKEN = '5D1TSxqADIkWkPHp7nxhjIMFtOfFB3aj'.freeze

  def self.send!
    send_request(RAYGUN_API_KEY, 'Rails app')
    send_request(RAYGUN_JS_API_KEY, 'JS app')
  end

  private

  def self.send_request(apiKey, env)
    uri = URI("https://app.raygun.io/deployments?authToken=#{RAYGUN_API_TOKEN}")

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'

    request.body = {
      'version': `git describe --abbrev=0`.strip,
      'ownerName': `git --no-pager show -s --format='%an' HEAD`.strip,
      'emailAddress': `git --no-pager show -s --format='%ae' HEAD`.strip,
      'comment': `git log -1 --pretty=%B`.strip,
      'scmIdentifier': `git rev-parse --verify --short HEAD`.strip,
      'apiKey': apiKey
    }.to_json

    begin
      puts "Notifying Raygun #{env} about release..."
      http.request(request)
      puts "\e[32mSuccess: Notified Raygun #{env} about release\e[0m"
    rescue
      puts "\e[31mError: Unable to notify Raygun #{env} about release!\e[0m"
    end
  end
end
