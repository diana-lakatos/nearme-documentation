namespace :new_admin do

  desc 'Setup New Admin'
  task setup: :environment do

    create_help_contents
  end

  def create_help_contents
    puts "\n\nCreating help contents for:"
    slugs = [
      'bulk-upload',
      'custom-attributes',
      'domains',
      'files',
      'general-settings',
      'home-search',
      'languages',
      'liquid-views',
      'pages',
      'reviews',
      'sms',
      'support-email',
      'text-filters',
      'theme-assets',
      'themes',
      'transactional-emails',
      'user-profiles',
      'user-roles',
      'users',
      'validations',
      'wish-lists',
      'graph-queries',
      'instance-rules',
    ]

    slugs.each do |slug|
      hc = HelpContent.find_or_initialize_by(slug: slug)
      hc.update!(content: '')
      puts "\t#{slug}\n"
    end

    # ASSET TYPE
    slug = 'asset-general'
    hc = HelpContent.find_or_initialize_by(slug: slug)
    hc.update!({
      content: "
## Asset types

Assets are the cornerstone of your marketplace. Regardless of what you are planning to be dealing with - lending books, selling merchandise, marketing projects, offering specialised services - we refer to all of these as assets.

You can define basic properties of a new asset type on the right. These will be used to create specific products, projects, services etc. later on.

You will be able to create as many different asset types as necessary.
      "
    })
    puts "\t#{slug}\n"

    # CUSTOM PROPS
    slug = 'asset-custom-properties'
    hc = HelpContent.find_or_initialize_by(slug: slug)

    hc.update!({
      content: "
# Custom properties

Good information architecture is _hard_. It also helps your users tremendousely in navigating the site and getting to where they want to be quickly.

We provide you with an option to add different custom properties that will describe your asset in a more meaningful way and connect them with other asset types in case you create any.

## Property types

### Category

Categories are working best in certain types of marketplaces with wide variety of different products e.g. online shops.

Categories allow you to put your assets into a tree like structure. This is the most common way of getting to information on e-commerce sites, where each step up the tree is more specific than the previous one, e.g. if your asset type is `Clothing` then you can have categories like `Men's Clothing - Tops - Sweaters`.

Categories are special in one more way, as you can limit other properties to belong to one specific category only. This way you can make sure products in certain categories contain all of the relevant information.

### Text
Most common and versatile type.

### Number
Apart from obvious purpose of storing numbers it comes with validation for minimum and maxium values entered by the user.

### Select one
An option to select one of the predefined choices. Can be displayed as simple select or radio buttons list.

### Select many
For all of your multiple selection needs - it allows you to collect information when more than one answer is possible.

### Date and time
Entering dates can be much easier with specialised helpers, and that’s the main purpose of this field.

### Yes / No
Simple checkboxes or a bit more fancy switches are very often used to answer simple questions, accept terms of use etc.
      "
    })
    puts "\t#{slug}\n"

    # LOCATION
    slug = 'asset-location'
    hc = HelpContent.find_or_initialize_by(slug: slug)

    hc.update!({
      content: "# Location

Does your asset have a physical location, that is important to the transaction? Good example of such assets would be any place you can rent like an offices, hotel rooms or vehicles.

Another good case is when services you want to offer are limited to a certain area, like walking dogs or babysitting.

To sum up, as long as you are not offering digital downloads or just shipping your products anywhere or offering online services, then you probably need a location.
      "
    })
    puts "\t#{slug}\n"

    # BOOKING
    slug = 'asset-booking'
    hc = HelpContent.find_or_initialize_by(slug: slug)

    hc.update!({
      content: "
# Booking and Renting

If you are interested in renting offices, cars, services - this section is for you.

You should turn on booking if you have a limited quantity of an asset that you want to make available to only one party at any given time.

It will enable features like scheduling availability, cancelations, pricing per period. With this setting on each listing is treated as a separate entity."
    })
    puts "\t#{slug}\n"
  end
end
