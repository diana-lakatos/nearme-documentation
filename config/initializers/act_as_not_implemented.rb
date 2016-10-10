
module ActiveRecord::ActAsNotImplemented
  extend ActiveSupport::Concern

  module ClassMethods
    def not_implemented(*args)
      args.each do |method_name, _method_returns|
        define_method method_name do |*_arguments|
          fail NotImplementedError
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::ActAsNotImplemented
