class GroupType < TransactableType

  SEARCH_VIEWS = %w(community)

  acts_as_paranoid

  has_many :form_components, as: :form_componentable
  has_many :groups, foreign_key: "transactable_type_id"

  def available_search_views
    SEARCH_VIEWS
  end

  def public?
    name.eql?('Public')
  end

  def moderated?
    name.eql?('Moderated')
  end

  def private?
    name.eql?('Private')
  end

  private

  def set_default_options
    super
    self.searcher_type ||= 'fulltext'
  end
end
