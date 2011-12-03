# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Add dummy data in development
if Rails.env.development?

  def log(object)
    puts "== #{object.inspect}"
    object
  end

  puts "Creating Workplaces"
  5.times do
    log(Factory(:workplace))
  end

end
