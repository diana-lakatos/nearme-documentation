class Domain
  module DomainMatcher

    extend ActiveSupport::Concern

    module ClassMethods

      def find_instance_by_request(request)
        subdomain = request.subdomain
        domain = request.domain
        begin
          Domain.where('name LIKE ? ', "*.#{domain}").first.try(:instance) ||
          Domain.where('name LIKE ? ', subdomain.present? ? subdomain+"."+domain : domain).first.try(:instance) ||
          Domain.where('name LIKE ? ', "www."+domain).first.try(:instance) ||
          Instance.find_by_name('DesksNearMe')
        rescue
          nil
        end

      end

    end

  end
end
