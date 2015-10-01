class ProjectType < TransactableType
  acts_as_paranoid
  has_many :form_components, as: :form_componentable
  has_many :categories, as: :categorizable, dependent: :destroy
  has_many :projects, foreign_key: "transactable_type_id"

  def to_liquid
    ProjectTypeDrop.new(self)
  end

  def wizard_path
    "/project_types/#{id}/project_wizard/new"
  end

  def buyable?
    false
  end
end

