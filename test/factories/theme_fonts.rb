# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :theme_font do
    theme
    regular_eot { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.eot'), 'application/vnd.ms-fontobject') }
    regular_svg { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.svg'), 'image/svg+xml') }
    regular_ttf { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.ttf'), 'application/octet-stream') }
    regular_woff { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.woff'), 'application/x-font-woff') }
    medium_eot { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-medium-web.eot'), 'application/vnd.ms-fontobject') }
    medium_svg { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-medium-web.svg'), 'image/svg+xml') }
    medium_ttf { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-medium-web.ttf'), 'application/octet-stream') }
    medium_woff { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-medium-web.woff'), 'application/x-font-woff') }
    bold_eot { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.eot'), 'application/vnd.ms-fontobject') }
    bold_svg { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.svg'), 'image/svg+xml') }
    bold_ttf { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.ttf'), 'application/octet-stream') }
    bold_woff { fixture_file_upload(Rails.root.join('app', 'frontend', 'fonts', 'futura-regular-web.woff'), 'application/x-font-woff') }
  end
end
