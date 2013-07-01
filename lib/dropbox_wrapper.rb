class DropboxWrapper

  def initialize
  end

  def connect
=begin
    if !@client 
      consumer = Dropbox::API::OAuth.consumer(:authorize)
      request_token = consumer.get_request_token
      puts "\nGo to this url and click 'Authorize' to get the token:"
      puts request_token.authorize_url
      query  = request_token.authorize_url.split('?').last
      params = CGI.parse(query)
      token  = params['oauth_token'].first
      print "\nOnce you authorize the app on Dropbox, press enter... "
      $stdin.gets.chomp
      access_token  = request_token.get_access_token(:oauth_verifier => token)
      puts "\nAuthorization complete!:\n\n"
      puts "  Dropbox::API::Config.app_key    = '#{consumer.key}'"
      puts "  Dropbox::API::Config.app_secret = '#{consumer.secret}'"
      puts "  client = Dropbox::API::Client.new(:token  => '#{access_token.token}', :secret => '#{access_token.secret}')"
      puts "\n"
      @client = Dropbox::API::Client.new(:token  => access_token.token, :secret => access_token.secret)
    end
=end
    Dropbox::API::Config.app_key    = 'bgce8czxteo40fp'
    Dropbox::API::Config.app_secret = 'bvg25p3f623vvi2'
    Dropbox::API::Client.new(:token  => '4uchsd05oy2fgxa', :secret => 'gje7ytijowkdzwx')
  end

  def client
    @client ||= connect
  end

  def get_files_for_path(folder_path = '/')
    begin
      client.ls(folder_path)
    rescue Dropbox::API::Error::NotFound
      []
    end
  end

  def download(file)
    file.downlod
  end

end
