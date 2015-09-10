module Draper
  module Decoratable

    def decorate(options = {})
      @decorator_object ||= decorator_class.decorate(self, options)
    end

  end
end