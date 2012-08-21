Given /^a Wi-Fi amenity$/ do
  @wifi = FactoryGirl.create(:amenity, name: "Wi-Fi", id: 123)
end