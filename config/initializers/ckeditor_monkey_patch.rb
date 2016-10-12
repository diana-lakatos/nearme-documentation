module Ckeditor
  class TextArea
    def initialize(template, options)
      # We want to prevent the textarea from having the ckeditor class because that
      # will cause the JS to automatically replace it with an editor with the default options;
      # it can be removed if it is shown that the ckeditor (without this patch) will be created with
      # the options passed in for the ckeditor input
      options = options.dup
      options[:class].delete(:ckeditor) if options[:class].present?

      @template = template
      @options = options.stringify_keys
      @ck_options = (@options.delete('ckeditor') || {}).stringify_keys
    end
  end
end
