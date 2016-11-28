module TagListHelper
  def data_tags_options(object)
    {
      "tags": {
        url: user_tags_url(current_user),
        prepopulate: object.respond_to?(:model) ? object.model.tags.as_json : object.tags.as_json
      }
    }
  end
end
