require "awesome_print"
AwesomePrint.pry!
Pry.config.exception_handler = proc do |output, exception, _pry_|
  output.puts "#{exception}"
  output.puts "#{exception.backtrace.join("\n\t")}".html_safe
end

if defined?(Rails) && Rails.env

  ActiveRecord::Base.class_eval do
    def self.[](id)
      find(id)
    end
  end

  def load_c(instance_id=1)
    Instance.find(instance_id).set_context!
  end
  alias lc load_c

  def drop_c
    PlatformContext.clear_current
  end
  alias dc load_c

  def saop
    save_and_open_page
  end

  def local_domain_setup
    Domain.find_each { |d| d.update_attribute(:name, d.name.gsub('near-me.com', 'lvh.me')) }
  end
  alias lds local_domain_setup

  puts "lc(instance) - to load instance context"
  puts "dc to drop current instance context"
  puts "lds to replace all near-me.com domains to lvh.me"
  puts "Default methods loaded from ./pryrc"
end
