class ProjectType < TransactableType
  acts_as_paranoid
  has_many :form_components, as: :form_componentable
  has_many :categories, as: :categorizable, dependent: :destroy
  has_many :projects, foreign_key: 'transactable_type_id'
  SEARCH_VIEWS = %w(community)

  def to_liquid
    ProjectTypeDrop.new(self)
  end

  def wizard_path(_options = {})
    "/project_types/#{id}/project_wizard/new"
  end

  def available_search_views
    SEARCH_VIEWS
  end

  private

  def set_default_options
    super
    self.searcher_type ||= 'fulltext'
  end
end
