
Factory.sequence :email do |n|
  "#{n}#{Time.now.to_f.to_s.gsub(/\./, '').slice(6, 20)}@example.com"
end

Factory.define :user do |u|
  u.email { Factory.next(:email) }
  u.remember_token "dummy_token"
  u.password 'password'
  u.password_confirmation 'password'
end

