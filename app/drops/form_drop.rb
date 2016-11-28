# frozen_string_literal: true
class FormDrop < BaseDrop
  # see gems/liquid-3.0.6/lib/liquid/drop.rb
  # specifically, implementation in line 35
  def before_method(method_name)
    if @source.respond_to?(method_name)
      @source.send(method_name)
    else
      "Unknowm method: #{method_name}. Please make sure if FormConfiguration includes it."
    end
  end

  def errors
    super.to_hash.stringify_keys
  end

  def respond_to_missing?(*args)
    @source.respond_to?(*args)
  end
end
