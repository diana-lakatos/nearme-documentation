ActsAsTaggableOn::Tagging.class_eval do
  auto_set_platform_context
  scoped_to_platform_context
end

Tagging = ActsAsTaggableOn::Tagging
