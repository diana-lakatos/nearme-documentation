class WeekDaysInput < SimpleForm::Inputs::CollectionCheckBoxesInput

  def input_type
    'check_boxes'
  end

  def collection
    @collection = [ ['M', 1] , ['T', 2], ['W', 3], ['TH', 4], ['F', 5], ['SA', 6], ['SU', 0] ]
  end

  def input_class
    "always-inline"
  end
end
