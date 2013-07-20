FactoryGirl.define do

  factory :instance do
    name 'DesksNearMe'
    site_name 'Desks Near Me'
    tagline 'Find a space to work'
    support_email 'support@desksnear.me'
    contact_email 'support@desksnear.me'
    address '185 Clara St #100, San Francisco CA 94107'
    phone_number '1.888.998.3375'
    support_url 'http://support.desksnear.me/'
    blog_url 'http://blog.desksnear.me/'
    twitter_url 'https://twitter.com/desksnearme'
    facebook_url 'https://www.facebook.com/DesksNearMe'
    partner
  end
end
