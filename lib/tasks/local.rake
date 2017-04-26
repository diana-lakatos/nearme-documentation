# frozen_string_literal: true
namespace :local do
  namespace :setup do
    desc 'Populate Payment Gateway with test settings'
    task all: :environment do
      Rake::Task['domains'].execute
      Rake::Task['payments'].execute
      Rake::Task['spacer'].execute
    end

    desc 'Populate Payment Gateway with test settings'
    task domains: :environment do
      unless Rails.env.development?
        puts 'Please run in development evnvironment'
        return
      end

      Domain.find_each { |d| d.update_attribute(:name, d.name.gsub('near-me.com', 'lvh.me')) }
    end

    desc 'Populate Payment Gateway with test settings'
    task payments: :environment do
      unless Rails.env.development?
        puts 'Please run in development evnvironment'
        return
      end

      puts '1. Setting Stripe'
      PaymentGateway::StripePaymentGateway.all.each do |pg|
        next if pg.test_settings
        pg.test_settings = { login: 'sk_test_sPLnOkI5mvXCoUuaqi5j6djR', publishable_key: 'pk_test_Xlb00cbXQN4YGxa5aeae73Ao' }
        pg.save
      end

      puts '2. Setting Stripe Connect'
      PaymentGateway::StripeConnectPaymentGateway.all.each do |pg|
        next if pg.test_settings
        pg.test_settings = { login: 'sk_test_sPLnOkI5mvXCoUuaqi5j6djR', publishable_key: 'pk_test_Xlb00cbXQN4YGxa5aeae73Ao' }
        pg.save
      end

      puts '3. Setting Braintree'
      PaymentGateway::BraintreePaymentGateway.all.each do |pg|
        next if pg.test_settings
        pg.test_settings = {
          merchant_id: 'jry7nqs72wcsqxtr',
          public_key: '7g9bjxznhnc2x244',
          private_key: 'cd6dc220d0585d332709d13497c8873b'
        }
        pg.save
      end

      puts '4. Setting Braintree Marketplace'
      PaymentGateway::BraintreePaymentGateway.all.each do |pg|
        next if pg.test_settings
        pg.test_settings = {
          merchant_id: 'jry7nqs72wcsqxtr',
          public_key: '7g9bjxznhnc2x244',
          private_key: 'cd6dc220d0585d332709d13497c8873b'
        }
        pg.save
      end
    end

    desc 'Clear Spacer scripts to remove JavaScript errors'
    task spacer: :environment do
      unless Rails.env.development?
        puts 'Please run in development evnvironment'
        return
      end

      instance = Instance.find(130)
      instance.set_context!
      instance.update_attributes(olark_enabled: false)

      ContentHolder.where("name LIKE '%Tracking%'").enabled.update_all(enabled: false)
      ContentHolder.where("content LIKE '%olark%'").enabled.update_all(enabled: false)
      ContentHolder.find_by(name: 'SCRIPTS GO HERE').update_attribute(content:
        "<script src=\"https://d2rw3as29v290b.cloudfront.net/instances/130/uploads/ckeditor/attachment_file/data/4181/main.js\"
        async></script>")
    end
  end
end
