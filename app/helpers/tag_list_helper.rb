module TagListHelper
  def data_tags_options(object)
    {
      "tags": {
        url: user_tags_url(current_user)
      }
    }
  end
end
