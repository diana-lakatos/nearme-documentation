module NearMe
  module Operation
    def self.included(base)
      base.class_eval do
        alias_method :_execute, :execute

        def execute
          _execute
          success 'Command succeeded: ' + self.class.to_s
        rescue
          failed 'error occured: ' + $ERROR_INFO.to_s
          raise $ERROR_INFO
        end

        private

        def success(message)
          puts message
        end

        def failed(message)
          puts message
        end
      end
    end
  end

  class Command
    def execute
    end
  end

  class DeleteHostedZoneCommand < Command
    def initialize(domain_name)
      @name = domain_name
    end

    def execute
      HostedZoneRepository.find_by_name(@name).delete
    end
  end

  DeleteHostedZoneCommand.send :include, Operation

  class DeleteELBCommand < Command
    def initialize(load_balancer_name)
      @load_balancer_name = load_balancer_name
    end

    def execute
      LoadBalancerRepository.delete(@load_balancer_name)
    end
  end

  DeleteELBCommand.send :include, Operation
end
