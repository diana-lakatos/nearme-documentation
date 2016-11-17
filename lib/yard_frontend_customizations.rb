# frozen_string_literal: true
class CustomVerifier < YARD::Verifier
  def run(obj_list)
    obj_list.reject do |obj|
      # Methods
      if obj.is_a?(YARD::CodeObjects::MethodObject)
        if obj.visibility == :private
          true
        else
          false
        end
      # Allowed parent objects
      elsif obj.is_a?(YARD::CodeObjects::ClassObject) && obj.path.match(/^Transactable$/) ||
            obj.is_a?(YARD::CodeObjects::ModuleObject) && obj.path.match(/^Support$/)
        false
      else
        # All other objects
        if (obj.is_a?(YARD::CodeObjects::ClassObject) && !(obj.path.match(/Drop$/) || obj.file.match(/^app\/liquid_tags\/.+?\.rb$/))) ||
           (obj.is_a?(YARD::CodeObjects::ModuleObject) && !obj.path.match(/LiquidFilters/))
          true
        else
          false
        end
      end
    end
  end
end

class YARD::CLI::YardocOptions
  def verifier
    CustomVerifier.new
  end
end
