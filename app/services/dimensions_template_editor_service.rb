# frozen_string_literal: true
# TODO: delete
class DimensionsTemplateEditorService
  def initialize(dimensions_template)
    @dimensions_template = dimensions_template
  end

  def save
    if @dimensions_template.save
      ensure_only_one_with_default_flag

      true
    else
      false
    end
  end

  def update_attributes(params)
    if @dimensions_template.update_attributes(params)
      ensure_only_one_with_default_flag

      true
    else
      false
    end
  end

  private

  def ensure_only_one_with_default_flag
    if @dimensions_template.use_as_default
      DimensionsTemplate.where.not(id: @dimensions_template.id).where(use_as_default: true).update_all(use_as_default: false)
    end
  end
end
