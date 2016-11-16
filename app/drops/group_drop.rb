class GroupDrop < BaseDrop
  # @return [GroupDrop]
  attr_reader :group

  # @!method name
  #   name of the group
  #   @return (see Group#name)
  delegate :name, to: :group

  def initialize(group)
    @group = group
  end

  # @return [String] path to the group
  def show_path
    routes.group_path(group)
  end

  # @return [String] url to the group
  def show_url
    urlify(show_path)
  end

  # @return [String] url for editing the group with included authentication token
  def edit_url_with_token
    urlify(routes.edit_dashboard_group_path(@group, token_key => @group.creator.try(:temporary_token), anchor: :collaborators))
  end
end
