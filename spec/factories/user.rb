Factory.define :user do |u|
  u.remember_token "dummy_token"
  u.association :login_account
end