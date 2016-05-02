module TagListHelper
  def data_tags_options(object)
    {
      "tags": {
        url: user_tags_url(current_user),
        prepopulate: object.tags.as_json
      }
    }
  end
end
