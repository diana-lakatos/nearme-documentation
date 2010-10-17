Factory.define(:authentication) do |a|
  a.provider "twitter"
  a.uid "ima_donkey"
  a.association :user
end