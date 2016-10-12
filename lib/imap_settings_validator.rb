require 'net/imap'

class ImapSettingsValidator
  def initialize(instance)
    @instance = instance
  end

  def validate_settings
    server = @instance.support_imap_server
    ssl = @instance.support_imap_ssl
    username = @instance.support_imap_username
    password = @instance.support_imap_password
    port = @instance.support_imap_port

    imap = Net::IMAP.new(server, port, ssl)
    imap.login(username, password)

    true
  rescue
    false
  end
end
