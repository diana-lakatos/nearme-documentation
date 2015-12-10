require 'liquid_view'
require 'liquid_blank_file_system'
require 'liquid_content_for'
require 'liquid_cache_for'

ActionView::Template.register_template_handler :liquid, LiquidView
