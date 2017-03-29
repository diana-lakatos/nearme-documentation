# frozen_string_literal: true
class FormDrop < BaseDrop
  # see documentation in bundle open liquid -> lib/liquid/drop.rb
  def liquid_method_missing(name)
    if @source.respond_to?(name)
      @source.send(name)
    else
      super
    end
  end

  def errors
    super.to_hash.stringify_keys
  end

  def respond_to_missing?(*args)
    @source.respond_to?(*args)
  end
end
