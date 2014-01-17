Raygun.setup do |config|
  if Rails.env.production?
    config.api_key = 'Wh44tvzgPN/Ea/JJN/i4JQ=='
  else
    config.api_key = '3VN6sPnvwRlTfwDmwhRFIA=='
  end

  [Listing::NotFound, Location::NotFound, Page::NotFound].each do |ignorable_exception|
    config.ignore << ignorable_exception
  end
end
