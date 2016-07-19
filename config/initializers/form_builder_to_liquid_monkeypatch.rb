class ActionView::Helpers::FormBuilder
  def to_liquid
    @form_builder_drop ||= SimpleForm::FormBuilderDrop.new(self)
  end
end

