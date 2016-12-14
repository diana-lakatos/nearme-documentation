module Utils
  class DatabaseConnectionHelper
    attr_accessor :pathname, :username, :password, :name, :host

    def initialize(pathname, &_block)
      @pathname = pathname
      @config   = YAML.load_file(Rails.root.join('config', 'database.yml'))[ENV['RAILS_ENV'] || 'development']
      @username = @config['username']
      @password = @config['password']
      @name     = @config['database']
      @host     = @config['host']
      @port     = @config['port'] || 5432
      yield self if block_given?
    end

    def build_dump_command
      "PGPASSWORD=#{@password} pg_dump -h #{@host} -p #{@port} -U #{@username} -f #{@pathname} -Fc #{@name} --exclude-table-data versions --exclude-table-data impressions --exclude-table-data marketplace_errors"
    end

    def build_restore_command
      "PGPASSWORD=#{@password} pg_restore --clean --no-acl --no-owner -h #{@host} -p #{@port} -U #{@username} -d #{@name} #{@pathname}"
    end
  end
end
