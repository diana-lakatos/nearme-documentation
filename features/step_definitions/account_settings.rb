When /^I upload avatar$/ do 
  avatar = File.join(Rails.root, *%w[features fixtures photos], "intern chair.jpg")
  attach_file(:avatar, avatar)
end

