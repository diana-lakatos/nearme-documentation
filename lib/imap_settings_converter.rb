class ImapSettingsConverter

  def initialize(instance)
    @instance = instance
  end

  def convert_hash
    symbolized_hash = nil
    begin
      symbolized_hash = YAML.load(@instance.support_imap_hash).symbolize_keys
    rescue
    end

    if symbolized_hash.present?
      # This hack is required otherwise it would not work because of a weird issue
      @instance.support_imap_password = symbolized_hash[:password]
      encrypted_password = @instance.encrypted_support_imap_password

      @instance.update_columns(support_imap_username: symbolized_hash[:username], encrypted_support_imap_password: encrypted_password, support_imap_server: symbolized_hash[:server], support_imap_port: symbolized_hash[:port], support_imap_ssl: symbolized_hash[:ssl])
    end
  end

end

