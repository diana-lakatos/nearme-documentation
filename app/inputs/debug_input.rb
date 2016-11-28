class DebugInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    binding.pry
    super
  end
end
