module Utils
  class DatabaseConnectionHelper
    attr_accessor :pathname, :username, :password, :name, :host

    def initialize(pathname, &block)
      @pathname = pathname
      @config   = YAML.load_file(Rails.root.join("config", "database.yml"))[ENV['RAILS_ENV'] || 'development']
      @username = @config['username']
      @password = @config['password']
      @name     = @config['database']
      @host     = @config['host']
      yield self if block_given?
    end

    def build_dump_command
      "PGPASSWORD=#{@password} pg_dump -h #{@host} -U #{@username} -f #{@pathname} -Fc #{@name}"
    end

    def build_restore_command
      "PGPASSWORD=#{@password} pg_restore --clean --no-acl --no-owner -h #{@host} -U #{@username} -d #{@name} #{@pathname}"
    end
  end
end
