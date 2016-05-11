class SimpleForm::FormBuilderDrop < BaseDrop

  delegate :object_name, :object, to: :source

end

