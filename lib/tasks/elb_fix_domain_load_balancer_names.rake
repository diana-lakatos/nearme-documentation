namespace :elb do
  desc 'print elb load-balancer-names list with matched domains'
  task :build_reports do
    balancers.map do |balancer|
      [balancer, [match_by_dns(balancer),
                  match_by_name(balancer),
                  no_match
                 ].compact.first.name
      ]
    end.to_a.sort{|a,b| b.last.to_s <=> a.last.to_s}.each do |row|
      puts row.inspect
    end
  end
end

def match_by_name balancer
  domains.find { |domain| domain.name =~ /#{balancer}/ }
end

def match_by_dns balancer
  domains.find { |domain| domain.to_dns_name == balancer }
end

def no_match
  Domain.new
end

def balancers
  ELBalancers::Names.new.fetch
end

def domains
  @domains ||= Domain.all
end


module ELBalancers
  REGIONS = %w(us-west-1 us-west-2)
  class Names
    def fetch
      regions.flat_map do |region|
        region.load_balancers.map(&:load_balancer_name)
      end
    end

    def regions
      REGIONS.map{ |name| Region.new(name) }
    end
  end

  class Region
    def initialize region
      @region = region
    end

    def load_balancers
      client.describe_load_balancers.load_balancer_descriptions
    end

    private

    def client
      AWS::ELB.new(region: @region).client
    end
  end
end
