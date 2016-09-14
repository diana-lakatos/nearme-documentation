class WeekDaysInput < SimpleForm::Inputs::CollectionCheckBoxesInput

  def input_type
    'check_boxes'
  end

  def collection
    @collection = [ [t('week.short.monday'), 1] , [t('week.short.tuesday'), 2], [t('week.short.wednesday'), 3], [t('week.short.thursday'), 4], [t('week.short.friday'), 5], [t('week.short.saturday'), 6], [t('week.short.sunday'), 0] ]
  end

  def input_class
    "always-inline"
  end
end
