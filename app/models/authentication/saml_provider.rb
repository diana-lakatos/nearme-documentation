class Authentication::SamlProvider
  def self.setup_proc
    lambda do |env|
      env['omniauth.strategy'].options[:issuer]                                      = 'devmesh-prod'
      env['omniauth.strategy'].options[:idp_sso_target_url]                          = 'https://sfederation.intel.com/federation/IDZ_Devmesh.asp'
      env['omniauth.strategy'].options[:idp_cert_fingerprint_validator]              = ->(fingerprint) { fingerprint }
      env['omniauth.strategy'].options[:name_identifier_format]                      = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    end
  end
end
