class ProjectDrop < BaseDrop
  attr_reader :project

  # id
  #   id of project as integer
  # name
  #   name of project as string
  delegate :id, :name, :description, :data_source_contents, :creator, :photos, to: :project

  def initialize(project)
    @project = project
  end

  # url to the "space listing" version of a first photo
  def cover_photo_url
    ActionController::Base.helpers.asset_url(@project.cover_photo.try(:image_url, :project_cover))
  end

  # url to the "large" version of a first photo
  def photo_large_url
    ActionController::Base.helpers.asset_url(@project.photos.first.try(:image_url, :large))
  end

  def show_path
    routes.project_path(@project)
  end

  def show_url
    urlify(show_path)
  end

  def edit_url
    urlify(routes.edit_dashboard_project_type_project_path(@project.transactable_type, @project))
  end

  def edit_url_with_token
    urlify(routes.edit_dashboard_project_type_project_path(@project.transactable_type, @project, token_key => @project.creator.try(:temporary_token), anchor: :collaborators))
  end

  def topics_names
    project.topics.pluck(:name).join(', ')
  end

end
