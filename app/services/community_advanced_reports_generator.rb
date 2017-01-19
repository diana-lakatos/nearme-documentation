class CommunityAdvancedReportsGenerator
  COLUMNS = {
    project_id: 'Project ID',
    project_created_at: 'Project Created At',
    project_name: 'Project Name',
    project_owner_id: 'Project Owner ID',
    project_owner_slug: 'Project Owner Slug',
    project_owner_name: 'Project Owner Name',
    project_slug: 'Project Slug',
    project_summary: 'Project Summary',
    project_description: 'Project Description',
    project_topics: 'Project Topics',
    project_groups: 'Project Groups',
    project_image_urls: 'Project Image URLs',
    project_links: 'Project Links',
    project_collaborators: 'Project Collaborators',
    project_video_url: 'Project Video URL',
    project_url: 'Project URL',
    project_state: 'Project State',
    project_owner_profile_url: 'Project Owner Profile URL',
    project_owner_email_address: 'Project Owner Email Address',
    project_owner_follower_count: 'Project Owner Follower Count',
    project_seeking_collaborators: 'Project Seeking Collaborators',
    project_collaborator_count: 'Project Collaborator Count',
    project_follower_count: 'Project Follower Count',
    project_featured_status: 'Project Featured Status',
    project_owner_location: 'Project Owner Location',
  }

  def initialize(params)
    @start_date = Time.zone.local_to_utc(DateTime.strptime(params[:day_start], '%Y-%m-%d')).in_time_zone
    @end_date = Time.zone.local_to_utc(DateTime.strptime(params[:day_end], '%Y-%m-%d')).in_time_zone
  end

  def search
    Transactable.where('created_at >= ? and created_at < ?', @start_date, @end_date).order('created_at ASC').collect do |project|
      COLUMNS.inject([]) do |project_values, column|
        project_values << get_project_attributes(project, column[0])
      end
    end
  end

  private

  def get_project_attributes(project, type)
    case type
    when :project_id
      project.id
    when :project_slug
      project.slug
    when :project_owner_id
      project.creator.id
    when :project_owner_slug
      project.creator.slug
    when :project_groups
      project.groups.map { |g| [g.id, g.name] }
    when :project_video_url
      project.properties.video_url
    when :project_created_at
      project.created_at
    when :project_name
      project.name
    when :project_url
      project.decorate.show_url
    when :project_state
      project.draft.present? ? 'Draft' : 'Published'
    when :project_owner_name
      project.creator.name
    when :project_owner_profile_url
      Rails.application.routes.url_helpers.profile_url(project.creator.slug)
    when :project_owner_email_address
      project.creator.email
    when :project_owner_follower_count
      project.creator.followers.count
    when :project_summary
      project.properties.summary
    when :project_description
      project.description
    when :project_topics
      project.topics.pluck(:name).join(',')
    when :project_image_urls
      project.photos.collect(&:original_image_url).join(',')
    when :project_links
      project.links.map { |link| [link.url, link.text, link.image.try(:url)] }
    when :project_seeking_collaborators
      project.seek_collaborators? ? 'Yes' : 'No'
    when :project_collaborators
      project.transactable_collaborators.collect { |collaborator| collaborator.user.slug }.join(',')
    when :project_collaborator_count
      project.transactable_collaborators.count
    when :project_follower_count
      project.followers_count
    when :project_featured_status
      project.featured? ? 'Yes' : 'No'
    when :project_owner_location
      project.creator.country.try(:name)
    end
  end
end
