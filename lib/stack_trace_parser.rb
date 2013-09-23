# class is used to extract desired informaton from array of strings returned by `caller()` method
# For example, one might want to get a name of a module from which method has been called,
# or a name of method that is a direct caller
# 
# Used for example in EventTracker, where we categorize events based on module to which
# event belongs. For example, module ListingEvents contains `created_a_listing()` method, which
# invokes `track()` method. Inside track, thanks to this method, we can easily get 'Listing Events' based 
# on caller
class StackTraceParser

  # example path_to_parse value: /Users/mkk/projects/rails/desksnearme/app/models/analytics/user_events.rb:14:in `logged_in'
  def initialize(path_to_parse)
    @path_to_parse = path_to_parse
  end
  
  def humanized_file_name
    @path_to_parse.split('/').last.split('.')[0].humanize
  end

  def humanized_method_name
    @path_to_parse.split('in `').last.split("'")[0].humanize
  end

end
