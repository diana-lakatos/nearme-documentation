FactoryGirl.define do

  factory :instance_view do
    body "%h1\n\tHello"
    path "public/index"
    locale "en"
    format "html"
    handler "haml"
    partial false
  end

end
