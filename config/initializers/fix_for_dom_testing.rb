# see https://github.com/rails/rails-dom-testing/issues/48
class SubstitutionContext
  def substitute_with_dup!(selector, *args)
    substitute_without_dup!(selector.dup, *args)
  end
  alias_method_chain :substitute!, :dup
end
