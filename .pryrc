require "awesome_print"
AwesomePrint.pry!
Pry.config.exception_handler = proc do |output, exception, _pry_|
  output.puts "#{exception}"
  output.puts "#{exception.backtrace.first(10)}"
end

if defined?(Rails) && Rails.env
  def load_c(instance_id=1)
    Instance.find(instance_id).set_context!
  end
  alias lc load_c

  def drop_c
    PlatformContext.clear_current
  end
  alias dc load_c

  def u
    User.find_by_email("lemkowski@gmail.com")
  end

  def r
    reload!
  end

  puts "lc(instance) - to load instance context"
  puts "dc to drop current instance context"
  puts "Default methods loaded from ./pryrc"
end
