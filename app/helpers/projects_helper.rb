module ProjectsHelper
  def project_video_embed_html(project)
    return unless project.properties.respond_to?(:video_url)
    video_embedder = Videos::VideoEmbedder.new(project.properties.video_url, iframe_attributes: { width: 350, height: 175 })
    video_embedder.html.html_safe
  end
end
