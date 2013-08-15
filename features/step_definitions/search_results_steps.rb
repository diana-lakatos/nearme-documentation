Given /^Auckland listing has prices: (.*), (.*), (.*)$/ do |daily_price, weekly_price, monthly_price|
  listing = Listing.last
  listing.daily_price = (daily_price=='nil' ? nil : daily_price)
  listing.weekly_price = (weekly_price=='nil' ? nil : weekly_price)
  listing.monthly_price = (monthly_price=='nil' ? nil : monthly_price)
  listing.free = true if !listing.has_price?
  listing.save!
end
