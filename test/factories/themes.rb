FactoryGirl.define do

  factory :theme do
    name 'DesksNearMe'
    site_name 'Desks Near Me'
    tagline 'Find a space to work'
    meta_title 'Desks Near Me'
    support_email 'support@desksnear.me'
    contact_email 'support@desksnear.me'
    address '185 Clara St #100, San Francisco CA 94107'
    phone_number '1.888.998.3375'
    support_url 'http://support.desksnear.me/'
    blog_url 'http://blog.desksnear.me/'
    gplus_url 'https://plus.google.com/115917701892962526160/'
    twitter_url 'https://twitter.com/desksnearme'
    facebook_url 'https://www.facebook.com/DesksNearMe'
    owner_id { PlatformContext.current.instance.id }
    owner_type "Instance"
    color_blue '41bf8b'
    color_red 'e83d33'
    color_orange 'FF8D00'
    color_green '6651af'
    color_black '1e2222'
    color_white 'fafafa'
    skip_compilation true

    factory :theme_with_logo_image do
      logo_image { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
    end

    factory :theme_with_compilation do
      skip_compilation false
    end
  end
end
