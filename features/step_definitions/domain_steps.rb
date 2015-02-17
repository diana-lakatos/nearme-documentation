Given /^a domain (.*) exists$/ do |domain_name|
  instance = Instance.first
  instance.domains << FactoryGirl.create(:domain, name: domain_name)
end
 