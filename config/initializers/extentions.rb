Dir[File.join(Rails.root, *%w(lib extentions ** *.rb))].each { |f| require f }
