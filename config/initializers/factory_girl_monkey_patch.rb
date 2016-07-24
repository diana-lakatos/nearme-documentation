# # Spree has few factories with the same names as ours.
# # We don't want to raise an exception.
# # Instead, we simply register factory with changed name.

# module FactoryGirl
#   class Decorator
#     class DisallowsDuplicatesRegistry < Decorator
#       def register(name, item)
#         if registered?(name)
#           @component.register("#{name}_engine".to_sym, item)
#         else
#           @component.register(name, item)
#         end
#       end
#     end
#   end

#   class Factory
#     public
#     def class_name
#       @class_name || parent.class_name || name
#     end
#   end
# end
