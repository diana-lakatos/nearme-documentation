module TagListHelper
  def data_tags_options(object)
    { 
      "tags": {
        url: tags_url,
        prepopulate: object.tags.as_json
      }
    }
  end
end