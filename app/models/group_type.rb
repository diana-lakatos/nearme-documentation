# frozen_string_literal: true
class GroupType < TransactableType
  SEARCH_VIEWS = %w(community).freeze

  acts_as_paranoid

  has_many :form_components, as: :form_componentable
  has_many :groups, foreign_key: 'transactable_type_id'

  scope :not_secret, -> { where.not(name: 'Secret') }

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

  # TODO: close your eyes...
  def secret?
    name.eql?('Secret')
  end

  def confidential?
    private? || secret?
  end

  private

  def set_default_options
    super
    self.searcher_type ||= 'fulltext'
  end
end
