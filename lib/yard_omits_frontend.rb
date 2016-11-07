class CustomVerifier < YARD::Verifier
  def run(obj_list)
    obj_list.reject do |obj|
      if (obj.is_a?(YARD::CodeObjects::ClassObject) && !obj.path.match(/Drop$/)) || obj.is_a?(YARD::CodeObjects::ModuleObject)
        true
      else
        false
      end
    end
  end
end

class YARD::CLI::YardocOptions

  def verifier
    CustomVerifier.new
  end

end
