class GroupDrop < BaseDrop
  attr_reader :group

  delegate :name, to: :group

  def initialize(group)
    @group = group
  end

  def show_path
    routes.group_path(group)
  end

  def show_url
    urlify(show_path)
  end

  def edit_url_with_token
    urlify(routes.edit_dashboard_group_path(@group, token_key => @group.creator.try(:temporary_token), anchor: :collaborators))
  end

end
