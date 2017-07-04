class CustomVerifier < YARD::Verifier
  def run(obj_list)
    obj_list.reject do |obj|
      # Exclusions
      if (obj.is_a?(YARD::CodeObjects::ClassObject) && class_exclusions.any? { |pattern| pattern.match(obj.path) }) ||
            (obj.is_a?(YARD::CodeObjects::MethodObject) && method_exclusions.any? { |pattern| pattern.match(obj.path) }) ||
            (obj.is_a?(YARD::CodeObjects::MethodObject) && obj.file.match(/^app\/forms\/.+?\.rb$/) && !obj.is_attribute?)
        true
      # Methods
      elsif obj.is_a?(YARD::CodeObjects::MethodObject)
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
        if (obj.is_a?(YARD::CodeObjects::ClassObject) && !(obj.path.match(/Drop$/) ||
                                                           obj.file.match(/^app\/liquid_tags\/.+?\.rb$/) ||
                                                           obj.file.match(/^app\/forms\/.+?\.rb$/))) ||
           (obj.is_a?(YARD::CodeObjects::ModuleObject) && !obj.path.match(/LiquidFilters/))
          true
        else
          false
        end
      end
    end
  end

  # We do it this way to avoid constant already initialized due to how yard loads this file
  def class_exclusions
    @class_exclusions = [
                          /CollectionNotDefinedError/,
                         /NameNotDefinedError/
                        ]
  end

  # We do it this way to avoid constant already initialized due to how yard loads this file
  def method_exclusions
    @method_exclusions ||= [
                             /#initialize$/
                           ]
  end

end

class YARD::CLI::YardocOptions
  def verifier
    CustomVerifier.new
  end
end
