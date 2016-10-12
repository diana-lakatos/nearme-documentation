module Draper
  module Decoratable
    def decorate(options = {})
      @decorator_object ||= begin
                              decorator_class.decorate(self, options)
                            rescue Draper::UninferrableDecoratorError
                              self
                            end
    end
  end
end
