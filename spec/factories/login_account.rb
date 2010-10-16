Factory.define :login_account, :class => Omnisocial::TwitterAccount do |a|
  a.remote_account_id 12345
  a.login 'dummy_login'
end