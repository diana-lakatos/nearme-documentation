class ServiceTypeSelectTag < TransactableTypeSelectTag
  def klass
    ServiceType
  end

  def classes
    %w(service-type-select-tag) + super
  end
end

