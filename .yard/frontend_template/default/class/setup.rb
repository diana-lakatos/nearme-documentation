def init
  return if !object.path.match(/Drop$/)
  super
  sections.place(:subclasses).before(:children)
  sections.place(:constructor_details, [T('method_details')]).before(:methodmissing)
end
