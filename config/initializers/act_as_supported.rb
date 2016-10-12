
module ActiveRecord::ActAsSupported
  extend ActiveSupport::Concern

  module ClassMethods
    def supported(*args)
      args.each do |method_name, _method_returns|
        define_method "supports_#{method_name}?" do
          true
        end
      end
    end

    def unsupported(*args)
      args.each do |method_name, _method_returns|
        define_method "supports_#{method_name}?" do
          false
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::ActAsSupported
