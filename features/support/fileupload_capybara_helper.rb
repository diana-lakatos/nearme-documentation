module FileuploadCapybaraHelper
  def attach_file_via_uploader
    page.execute_script "$('.browse-file').click()"
  end
end

World(FileuploadCapybaraHelper)
