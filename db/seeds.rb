# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Add dummy data in development
if Rails.env.development? || Rails.env.staging?

  def log(object)
    puts "== #{object.inspect}"
    object
  end

  if(Location.count==0)

    coffee = FactoryGirl.create(:amenity, :name => "Coffee")
    wifi = FactoryGirl.create(:amenity, :name => "Wifi")
    kitchen = FactoryGirl.create(:amenity, :name => "Kitchen")
    amenities = [
      [coffee],
      [coffee, wifi],
      [coffee, wifi, kitchen]
    ]

    locations = [
      log(FactoryGirl.create(:location_in_auckland, :amenities => amenities.sample)),
      log(FactoryGirl.create(:location_in_cleveland, :amenities => amenities.sample)),
      log(FactoryGirl.create(:location_in_san_francisco, :amenities => amenities.sample))
    ]

    locations.each do |location|
      listing =  FactoryGirl.create(:listing, :location => location)
    end

    ["Business", "Co-working", "Public"].each do |name|
      LocationType.create(:name => name)
    end
    business_location = LocationType.find_by_name("Business")
    Location.update_all(:location_type_id => business_location.id)

  end

end

 



["Accounting", "Airlines/Aviation", "Alternative Dispute Resolution", "Alternative Medicine",
 "Animation", "Apparel & Fashion", "Architecture & Planning", "Arts and Crafts", "Automotive",
 "Aviation & Aerospace", "Banking", "Biotechnology", "Broadcast Media", "Building Materials",
 "Business Supplies and Equipment", "Capital Markets", "Chemicals", "Civic & Social Organization",
 "Civil Engineering", "Commercial Real Estate", "Computer & Network Security", "Computer Games",
 "Computer Hardware", "Computer Networking", "Computer Software", "Construction", "Consumer Electronics",
 "Consumer Goods", "Consumer Services", "Cosmetics", "Dairy", "Defense & Space", "Design",
 "Education Management", "E-Learning", "Electrical/Electronic Manufacturing", "Entertainment",
 "Environmental Services", "Events Services", "Executive Office", "Facilities Services",
 "Farming", "Financial Services", "Fine Art", "Fishery", "Food & Beverages", "Food Production",
 "Fund-Raising", "Furniture", "Gambling & Casinos", "Glass, Ceramics & Concrete",
 "Government Administration", "Government Relations", "Graphic Design", "Health, Wellness and Fitness",
 "Higher Education", "Hospital & Health Care", "Hospitality", "Human Resources", "Import and Export",
 "Individual & Family Services", "Industrial Automation", "Information Services", "Information Technology and Services",
 "Insurance", "International Affairs", "International Trade and Development", "Internet", "Investment Banking",
 "Investment Management", "Judiciary", "Law Enforcement", "Law Practice", "Legal Services", "Legislative Office",
 "Leisure, Travel & Tourism", "Libraries", "Logistics and Supply Chain", "Luxury Goods & Jewelry", "Machinery",
 "Management Consulting", "Maritime", "Marketing and Advertising", "Market Research", "Mechanical or Industrial Engineering",
 "Media Production", "Medical Devices", "Medical Practice", "Mental Health Care", "Military",
 "Mining & Metals", "Motion Pictures and Film", "Museums and Institutions", "Music", "Nanotechnology",
 "Newspapers", "Nonprofit Organization Management", "Oil & Energy", "Online Media", "Outsourcing/Offshoring",
 "Package/Freight Delivery", "Packaging and Containers", "Paper & Forest Products", "Performing Arts",
 "Pharmaceuticals", "Philanthropy", "Photography", "Plastics", "Political Organization", "Primary/Secondary Education",
 "Printing", "Professional Training & Coaching", "Program Development", "Public Policy",
 "Public Relations and Communications", "Public Safety", "Publishing", "Railroad Manufacture", "Ranching",
 "Real Estate", "Recreational Facilities and Services", "Religious Institutions", "Renewables & Environment",
 "Research", "Restaurants", "Retail", "Security and Investigations", "Semiconductors", "Shipbuilding",
 "Sporting Goods", "Sports", "Staffing and Recruiting", "Supermarkets", "Telecommunications", "Textiles",
 "Think Tanks", "Tobacco", "Translation and Localization", "Transportation/Trucking/Railroad", "Utilities",
 "Venture Capital & Private Equity", "Veterinary", "Warehousing", "Wholesale", "Wine and Spirits",
 "Wireless", "Writing and Editing"].each do |name|
    log(Industry.create(:name => name)) unless Industry.find_by_name(name)
  end
